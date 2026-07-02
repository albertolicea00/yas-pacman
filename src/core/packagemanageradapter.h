#pragma once

#include <QList>
#include <QObject>

#include "clicommand.h"
#include "package.h"

namespace yas {

// Contract implemented once per package manager (brew, apt, winget, ...).
// Adapters only *describe* commands and parse their output; execution,
// queueing, logging and privilege handling live in the core.
class PackageManagerAdapter : public QObject {
    Q_OBJECT
public:
    using QObject::QObject;
    ~PackageManagerAdapter() override = default;

    virtual QString displayName() const = 0;  // "Homebrew"
    virtual QString cliProgram() const = 0;   // "brew"
    // Extra locations to look for the CLI (GUI apps do not inherit shell PATH).
    virtual QStringList cliSearchPaths() const { return {}; }
    virtual QStringList cliVersionArguments() const
    {
        return {QStringLiteral("--version")};
    }

    // Command builders. `kind` is the Package::kind of the target when known;
    // adapters that need it (e.g. brew casks) use it to add flags.
    virtual CliCommand searchCommand(const QString &query) const = 0;
    virtual CliCommand infoCommand(const QString &packageId, const QString &kind) const = 0;
    virtual CliCommand listInstalledCommand() const = 0;
    virtual CliCommand listOutdatedCommand() const = 0;
    virtual CliCommand installCommand(const QString &packageId, const QString &kind) const = 0;
    virtual CliCommand uninstallCommand(const QString &packageId, const QString &kind) const = 0;
    virtual CliCommand upgradeCommand(const QString &packageId, const QString &kind) const = 0;
    virtual CliCommand upgradeAllCommand() const = 0;
    // Optional capabilities: return an invalid CliCommand to hide the feature.
    virtual CliCommand pinCommand(const QString &, const QString &) const { return {}; }
    virtual CliCommand unpinCommand(const QString &, const QString &) const { return {}; }

    // Output parsers, paired with the builders above.
    virtual QList<Package> parseSearch(const QString &stdOut) const = 0;
    virtual QList<Package> parseInfo(const QString &stdOut) const = 0;
    virtual QList<Package> parseInstalled(const QString &stdOut) const = 0;
    virtual QList<Package> parseOutdated(const QString &stdOut) const = 0;

    // Full CLI coverage: everything beyond the core flow (doctor, cache clean,
    // dependency trees, taps/buckets/remotes...). Rendered in the Actions view.
    virtual QList<CliAction> actionCatalog() const { return {}; }

    CliAction actionById(const QString &id) const
    {
        const auto catalog = actionCatalog();
        for (const auto &action : catalog) {
            if (action.id == id)
                return action;
        }
        return {};
    }
};

} // namespace yas
