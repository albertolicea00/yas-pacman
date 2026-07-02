#pragma once

#include <QMap>
#include <QString>
#include <QStringList>

namespace yas {

// A fully-resolved CLI invocation. Arguments are always passed as a list —
// never interpolate user input into a shell string.
struct CliCommand {
    QString program;
    QStringList arguments;
    QMap<QString, QString> extraEnv;

    bool isValid() const { return !program.isEmpty(); }
    QString displayString() const
    {
        return (QStringList(program) + arguments).join(QLatin1Char(' '));
    }
};

// One entry of the full-coverage command catalog ("Actions" view). Lets the UI
// expose every function of the wrapped CLI, not just the core install flow.
struct CliAction {
    QString id;           // e.g. "doctor"
    QString title;        // e.g. "Run diagnostics"
    QString description;
    CliCommand command;
    bool needsPackage = false;  // command receives the selected package id as last arg
    bool destructive = false;   // UI must confirm before running
    bool refreshAfter = false;  // refresh installed/outdated lists when done
};

} // namespace yas
