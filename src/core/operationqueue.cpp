#include "operationqueue.h"

#include "commandlog.h"
#include "processrunner.h"

namespace yas {

OperationQueue::OperationQueue(ProcessRunner *runner, CommandLog *log, QObject *parent)
    : QObject(parent)
    , m_runner(runner)
    , m_log(log)
{
    connect(m_runner, &ProcessRunner::finished, this,
            [this](int exitCode, const QString &stdOut, const QString &stdErr) {
                if (m_log)
                    m_log->commandFinished(exitCode);
                finishCurrent(exitCode == 0, stdOut, stdErr);
            });
    connect(m_runner, &ProcessRunner::failedToStart, this, [this](const QString &error) {
        if (m_log)
            m_log->commandFinished(-1);
        finishCurrent(false, {}, error);
    });
}

void OperationQueue::enqueue(Operation operation)
{
    m_pending.enqueue(std::move(operation));
    emit pendingCountChanged();
    if (!m_active)
        startNext();
}

void OperationQueue::cancelCurrent()
{
    m_runner->cancel();
}

void OperationQueue::clearPending()
{
    if (m_pending.isEmpty())
        return;
    m_pending.clear();
    emit pendingCountChanged();
}

void OperationQueue::startNext()
{
    if (m_pending.isEmpty())
        return;
    m_current = m_pending.dequeue();
    m_active = true;
    emit pendingCountChanged();
    emit currentChanged();
    emit busyChanged();
    if (m_log)
        m_log->commandStarted(m_current.command.displayString());
    m_runner->start(m_current.command);
}

void OperationQueue::finishCurrent(bool ok, const QString &stdOut, const QString &stdErr)
{
    if (!m_active)
        return;
    const Operation finished = std::move(m_current);
    m_current = {};
    m_active = false;
    emit currentChanged();
    emit busyChanged();

    if (finished.onFinished)
        finished.onFinished(ok, stdOut, stdErr);
    emit operationFinished(finished.kind, finished.packageId, ok);

    startNext();
}

} // namespace yas
