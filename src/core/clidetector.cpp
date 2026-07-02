#include "clidetector.h"

#include <QProcess>
#include <QStandardPaths>

namespace yas {

CliInfo CliDetector::detect(const QString &program, const QStringList &searchPaths,
                            const QStringList &versionArguments)
{
    CliInfo info;
    info.path = QStandardPaths::findExecutable(program);
    if (info.path.isEmpty() && !searchPaths.isEmpty())
        info.path = QStandardPaths::findExecutable(program, searchPaths);
    if (info.path.isEmpty())
        return info;

    info.found = true;
    QProcess process;
    process.start(info.path, versionArguments);
    if (process.waitForFinished(5000)) {
        const QString out = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
        info.version = out.section(QLatin1Char('\n'), 0, 0);
    }
    return info;
}

} // namespace yas
