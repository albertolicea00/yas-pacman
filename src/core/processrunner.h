#pragma once

#include <QObject>
#include <QProcess>
#include <QStringList>

#include "clicommand.h"

namespace yas {

// Executes one CliCommand at a time via QProcess, streaming output line by
// line. Resolves the program explicitly because GUI apps on macOS/Linux do
// not inherit the interactive shell PATH.
class ProcessRunner : public QObject {
    Q_OBJECT
public:
    explicit ProcessRunner(QObject *parent = nullptr);

    void setSearchPaths(const QStringList &paths);
    QStringList searchPaths() const { return m_searchPaths; }
    QString resolveProgram(const QString &program) const;
    bool running() const;

    void start(const CliCommand &command);
    void cancel();

signals:
    void started(const QString &commandLine);
    void outputLine(const QString &line, bool isStdErr);
    void finished(int exitCode, const QString &stdOut, const QString &stdErr);
    void failedToStart(const QString &error);

private:
    void flushBuffer(QString &buffer, bool isStdErr);
    void appendChunk(QString &buffer, QString &accumulated, const QByteArray &chunk,
                     bool isStdErr);

    QProcess m_process;
    QStringList m_searchPaths;
    QString m_stdOut;
    QString m_stdErr;
    QString m_bufOut;
    QString m_bufErr;
    bool m_cancelled = false;
};

} // namespace yas
