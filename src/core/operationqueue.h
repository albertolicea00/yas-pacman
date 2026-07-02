#pragma once

#include <QObject>
#include <QQueue>
#include <functional>

#include "clicommand.h"

namespace yas {

class ProcessRunner;
class CommandLog;

// One queued CLI operation with a completion callback.
struct Operation {
    QString kind;      // "search", "install", "action:doctor"...
    QString packageId; // empty for global operations
    CliCommand command;
    std::function<void(bool ok, const QString &stdOut, const QString &stdErr)> onFinished;
};

// Serializes all CLI work: package managers do not tolerate concurrent runs
// (dpkg/pacman locks, brew races). One operation at a time, FIFO.
class OperationQueue : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString currentKind READ currentKind NOTIFY currentChanged)
    Q_PROPERTY(QString currentPackageId READ currentPackageId NOTIFY currentChanged)
    Q_PROPERTY(int pendingCount READ pendingCount NOTIFY pendingCountChanged)
public:
    OperationQueue(ProcessRunner *runner, CommandLog *log, QObject *parent = nullptr);

    void enqueue(Operation operation);

    bool busy() const { return m_active; }
    QString currentKind() const { return m_current.kind; }
    QString currentPackageId() const { return m_current.packageId; }
    int pendingCount() const { return int(m_pending.size()); }

    Q_INVOKABLE void cancelCurrent();
    Q_INVOKABLE void clearPending();

signals:
    void busyChanged();
    void currentChanged();
    void pendingCountChanged();
    void operationFinished(const QString &kind, const QString &packageId, bool ok);

private:
    void startNext();
    void finishCurrent(bool ok, const QString &stdOut, const QString &stdErr);

    ProcessRunner *m_runner;
    CommandLog *m_log;
    QQueue<Operation> m_pending;
    Operation m_current;
    bool m_active = false;
};

} // namespace yas
