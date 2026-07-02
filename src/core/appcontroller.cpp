#include "appcontroller.h"

namespace yas {

AppController::AppController(PackageManagerAdapter *adapter, QObject *parent)
    : QObject(parent)
    , m_adapter(adapter)
    , m_queue(&m_runner, &m_log)
{
    m_runner.setSearchPaths(m_adapter->cliSearchPaths());

    connect(&m_runner, &ProcessRunner::outputLine, this, &AppController::terminalOutput);
    connect(&m_runner, &ProcessRunner::started, this, &AppController::commandStarted);
    connect(&m_runner, &ProcessRunner::finished, this,
            [this](int exitCode, const QString &, const QString &) {
                emit commandFinished(exitCode);
            });

    redetectCli();
}

QVariantList AppController::actions() const
{
    QVariantList list;
    const auto catalog = m_adapter->actionCatalog();
    for (const CliAction &action : catalog) {
        list.append(QVariantMap{
            {QStringLiteral("actionId"), action.id},
            {QStringLiteral("title"), action.title},
            {QStringLiteral("description"), action.description},
            {QStringLiteral("needsPackage"), action.needsPackage},
            {QStringLiteral("destructive"), action.destructive},
            {QStringLiteral("commandPreview"), action.command.displayString()},
        });
    }
    return list;
}

void AppController::initialize()
{
    if (!m_cli.found)
        return;
    refreshAll();
}

void AppController::redetectCli()
{
    m_cli = CliDetector::detect(m_adapter->cliProgram(), m_adapter->cliSearchPaths(),
                                m_adapter->cliVersionArguments());
    emit cliChanged();
}

void AppController::search(const QString &query)
{
    const QString trimmed = query.trimmed();
    if (trimmed.isEmpty()) {
        m_searchModel.setPackages({});
        return;
    }
    m_queue.enqueue({QStringLiteral("search"), {}, m_adapter->searchCommand(trimmed),
                     [this](bool ok, const QString &out, const QString &) {
                         if (!ok)
                             return;
                         auto packages = m_adapter->parseSearch(out);
                         annotateInstalled(packages);
                         m_searchModel.setPackages(std::move(packages));
                     }});
}

void AppController::requestInfo(const QString &packageId, const QString &kind)
{
    m_queue.enqueue({QStringLiteral("info"), packageId,
                     m_adapter->infoCommand(packageId, kind),
                     [this](bool ok, const QString &out, const QString &) {
                         if (!ok)
                             return;
                         const auto packages = m_adapter->parseInfo(out);
                         if (!packages.isEmpty())
                             emit infoReady(PackageListModel::toMap(packages.first()));
                     }});
}

void AppController::refreshInstalled()
{
    m_queue.enqueue({QStringLiteral("refresh-installed"), {},
                     m_adapter->listInstalledCommand(),
                     [this](bool ok, const QString &out, const QString &) {
                         if (!ok)
                             return;
                         auto packages = m_adapter->parseInstalled(out);
                         m_installedIndex.clear();
                         for (const Package &p : packages)
                             m_installedIndex.insert(p.id, p);
                         m_installedModel.setPackages(std::move(packages));
                     }});
}

void AppController::refreshOutdated()
{
    m_queue.enqueue({QStringLiteral("refresh-outdated"), {},
                     m_adapter->listOutdatedCommand(),
                     [this](bool ok, const QString &out, const QString &) {
                         if (!ok)
                             return;
                         m_outdatedModel.setPackages(m_adapter->parseOutdated(out));
                     }});
}

void AppController::install(const QString &packageId, const QString &kind)
{
    enqueueMutation(QStringLiteral("install"), packageId,
                    m_adapter->installCommand(packageId, kind),
                    tr("Installed %1").arg(packageId));
}

void AppController::uninstall(const QString &packageId, const QString &kind)
{
    enqueueMutation(QStringLiteral("uninstall"), packageId,
                    m_adapter->uninstallCommand(packageId, kind),
                    tr("Uninstalled %1").arg(packageId));
}

void AppController::upgrade(const QString &packageId, const QString &kind)
{
    enqueueMutation(QStringLiteral("upgrade"), packageId,
                    m_adapter->upgradeCommand(packageId, kind),
                    tr("Upgraded %1").arg(packageId));
}

void AppController::upgradeAll()
{
    enqueueMutation(QStringLiteral("upgrade-all"), {}, m_adapter->upgradeAllCommand(),
                    tr("All packages upgraded"));
}

bool AppController::canPin(const QString &packageId, const QString &kind) const
{
    return m_adapter->pinCommand(packageId, kind).isValid();
}

void AppController::pin(const QString &packageId, const QString &kind)
{
    enqueueMutation(QStringLiteral("pin"), packageId,
                    m_adapter->pinCommand(packageId, kind),
                    tr("Pinned %1").arg(packageId));
}

void AppController::unpin(const QString &packageId, const QString &kind)
{
    enqueueMutation(QStringLiteral("unpin"), packageId,
                    m_adapter->unpinCommand(packageId, kind),
                    tr("Unpinned %1").arg(packageId));
}

void AppController::runAction(const QString &actionId, const QString &packageId)
{
    CliAction action = m_adapter->actionById(actionId);
    if (!action.command.isValid())
        return;
    CliCommand command = action.command;
    if (action.needsPackage) {
        if (packageId.isEmpty()) {
            emit toast(tr("Select a package first"), true);
            return;
        }
        command.arguments.append(packageId);
    }
    const bool refresh = action.refreshAfter;
    const QString title = action.title;
    m_queue.enqueue({QStringLiteral("action:") + actionId, packageId, command,
                     [this, refresh, title](bool ok, const QString &, const QString &err) {
                         emit toast(ok ? tr("%1 — done").arg(title)
                                       : tr("%1 — failed: %2").arg(title, err.left(200)),
                                    !ok);
                         if (ok && refresh)
                             refreshAll();
                     }});
}

QString AppController::actionCommandPreview(const QString &actionId) const
{
    return m_adapter->actionById(actionId).command.displayString();
}

bool AppController::hasAction(const QString &actionId) const
{
    return m_adapter->actionById(actionId).command.isValid();
}

void AppController::fetchActionOutput(const QString &actionId, const QString &packageId)
{
    const CliAction action = m_adapter->actionById(actionId);
    if (!action.command.isValid())
        return;
    CliCommand command = action.command;
    if (action.needsPackage && !packageId.isEmpty())
        command.arguments.append(packageId);
    m_queue.enqueue({QStringLiteral("fetch:") + actionId, packageId, command,
                     [this, actionId, packageId](bool ok, const QString &out, const QString &err) {
                         emit actionOutputReady(actionId, packageId,
                                                ok ? out : err, ok);
                     }});
}

void AppController::enqueueMutation(const QString &kind, const QString &packageId,
                                    const CliCommand &command,
                                    const QString &successMessage)
{
    if (!command.isValid()) {
        emit toast(tr("Operation not supported by %1").arg(managerName()), true);
        return;
    }
    m_queue.enqueue({kind, packageId, command,
                     [this, successMessage](bool ok, const QString &, const QString &err) {
                         emit toast(ok ? successMessage
                                       : tr("Failed: %1").arg(err.left(200)),
                                    !ok);
                         if (ok)
                             refreshAll();
                     }});
}

void AppController::refreshAll()
{
    refreshInstalled();
    refreshOutdated();
}

void AppController::annotateInstalled(QList<Package> &packages) const
{
    for (Package &p : packages) {
        const auto it = m_installedIndex.constFind(p.id);
        if (it != m_installedIndex.constEnd()) {
            p.installedVersion = it->installedVersion;
            p.pinned = it->pinned;
            if (p.version.isEmpty())
                p.version = it->version;
        }
    }
}

} // namespace yas
