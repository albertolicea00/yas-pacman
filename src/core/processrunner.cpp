#include "processrunner.h"

#include <QFileInfo>
#include <QProcessEnvironment>
#include <QStandardPaths>

namespace yas {

ProcessRunner::ProcessRunner(QObject *parent)
    : QObject(parent)
{
    connect(&m_process, &QProcess::readyReadStandardOutput, this, [this] {
        appendChunk(m_bufOut, m_stdOut, m_process.readAllStandardOutput(), false);
    });
    connect(&m_process, &QProcess::readyReadStandardError, this, [this] {
        appendChunk(m_bufErr, m_stdErr, m_process.readAllStandardError(), true);
    });
    connect(&m_process, &QProcess::finished, this,
            [this](int exitCode, QProcess::ExitStatus status) {
                flushBuffer(m_bufOut, false);
                flushBuffer(m_bufErr, true);
                const int code =
                    (status == QProcess::NormalExit && !m_cancelled) ? exitCode : -1;
                emit finished(code, m_stdOut, m_stdErr);
            });
    connect(&m_process, &QProcess::errorOccurred, this, [this](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart)
            emit failedToStart(m_process.errorString());
    });
}

void ProcessRunner::setSearchPaths(const QStringList &paths)
{
    m_searchPaths = paths;
}

QString ProcessRunner::resolveProgram(const QString &program) const
{
    const QFileInfo info(program);
    if (info.isAbsolute())
        return info.isExecutable() ? program : QString();

    QString found = QStandardPaths::findExecutable(program);
    if (found.isEmpty() && !m_searchPaths.isEmpty())
        found = QStandardPaths::findExecutable(program, m_searchPaths);
    return found;
}

bool ProcessRunner::running() const
{
    return m_process.state() != QProcess::NotRunning;
}

void ProcessRunner::start(const CliCommand &command)
{
    if (running()) {
        emit failedToStart(QStringLiteral("A command is already running"));
        return;
    }
    const QString program = resolveProgram(command.program);
    if (program.isEmpty()) {
        emit failedToStart(
            QStringLiteral("Executable not found: %1").arg(command.program));
        return;
    }

    m_stdOut.clear();
    m_stdErr.clear();
    m_bufOut.clear();
    m_bufErr.clear();
    m_cancelled = false;

    // Subcommands spawned by the manager (git, curl...) need the same PATH
    // extension the GUI used to find the manager itself.
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    if (!m_searchPaths.isEmpty()) {
        const QString path = env.value(QStringLiteral("PATH"));
        env.insert(QStringLiteral("PATH"),
                   m_searchPaths.join(QLatin1Char(':')) + QLatin1Char(':') + path);
    }
    for (auto it = command.extraEnv.constBegin(); it != command.extraEnv.constEnd(); ++it)
        env.insert(it.key(), it.value());
    m_process.setProcessEnvironment(env);

    emit started(command.displayString());
    m_process.start(program, command.arguments);
}

void ProcessRunner::cancel()
{
    if (!running())
        return;
    m_cancelled = true;
    m_process.terminate();
    if (!m_process.waitForFinished(3000))
        m_process.kill();
}

void ProcessRunner::appendChunk(QString &buffer, QString &accumulated,
                                const QByteArray &chunk, bool isStdErr)
{
    const QString text = QString::fromUtf8(chunk);
    accumulated += text;
    buffer += text;
    qsizetype pos = 0;
    qsizetype newline;
    while ((newline = buffer.indexOf(QLatin1Char('\n'), pos)) != -1) {
        emit outputLine(buffer.mid(pos, newline - pos), isStdErr);
        pos = newline + 1;
    }
    buffer.remove(0, pos);
}

void ProcessRunner::flushBuffer(QString &buffer, bool isStdErr)
{
    if (!buffer.isEmpty()) {
        emit outputLine(buffer, isStdErr);
        buffer.clear();
    }
}

} // namespace yas
