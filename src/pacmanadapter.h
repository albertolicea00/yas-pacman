#pragma once

#include "packagemanageradapter.h"

class PacmanAdapter : public yas::PackageManagerAdapter {
    Q_OBJECT
public:
    using yas::PackageManagerAdapter::PackageManagerAdapter;

    QString displayName() const override;
    QString cliProgram() const override;
    QStringList cliSearchPaths() const override;
    QStringList cliVersionArguments() const override;

    yas::CliCommand searchCommand(const QString &query) const override;
    yas::CliCommand infoCommand(const QString &packageId, const QString &kind) const override;
    yas::CliCommand listInstalledCommand() const override;
    yas::CliCommand listOutdatedCommand() const override;
    yas::CliCommand installCommand(const QString &packageId, const QString &kind) const override;
    yas::CliCommand uninstallCommand(const QString &packageId, const QString &kind) const override;
    yas::CliCommand upgradeCommand(const QString &packageId, const QString &kind) const override;
    yas::CliCommand upgradeAllCommand() const override;
    yas::CliCommand pinCommand(const QString &packageId, const QString &kind) const override;
    yas::CliCommand unpinCommand(const QString &packageId, const QString &kind) const override;

    QList<yas::Package> parseSearch(const QString &stdOut) const override;
    QList<yas::Package> parseInfo(const QString &stdOut) const override;
    QList<yas::Package> parseInstalled(const QString &stdOut) const override;
    QList<yas::Package> parseOutdated(const QString &stdOut) const override;

    QList<yas::CliAction> actionCatalog() const override;
};
