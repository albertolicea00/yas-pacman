#pragma once

#include <QString>
#include <QStringList>

namespace yas {

struct CliInfo {
    bool found = false;
    QString path;
    QString version; // first line of `<cli> --version`
};

// Synchronous startup probe for the wrapped CLI. Fast; runs once at launch.
class CliDetector {
public:
    static CliInfo detect(const QString &program, const QStringList &searchPaths,
                          const QStringList &versionArguments);
};

} // namespace yas
