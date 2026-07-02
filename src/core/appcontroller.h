#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include "clidetector.h"
#include "commandlog.h"
#include "operationqueue.h"
#include "packagelistmodel.h"
#include "packagemanageradapter.h"
#include "processrunner.h"

namespace yas {

// Single facade exposed to QML as the `App` context property. Owns the
// runner, queue, log and models; translates UI intents into adapter commands.
class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString managerName READ managerName CONSTANT)
    Q_PROPERTY(bool cliAvailable READ cliAvailable NOTIFY cliChanged)
    Q_PROPERTY(QString cliPath READ cliPath NOTIFY cliChanged)
    Q_PROPERTY(QString cliVersion READ cliVersion NOTIFY cliChanged)
    Q_PROPERTY(yas::OperationQueue *queue READ queue CONSTANT)
    Q_PROPERTY(yas::CommandLog *commandLog READ commandLog CONSTANT)
    Q_PROPERTY(yas::PackageListModel *searchModel READ searchModel CONSTANT)
    Q_PROPERTY(yas::PackageListModel *installedModel READ installedModel CONSTANT)
    Q_PROPERTY(yas::PackageListModel *outdatedModel READ outdatedModel CONSTANT)
    Q_PROPERTY(QVariantList actions READ actions CONSTANT)
public:
    explicit AppController(PackageManagerAdapter *adapter, QObject *parent = nullptr);

    QString managerName() const { return m_adapter->displayName(); }
    bool cliAvailable() const { return m_cli.found; }
    QString cliPath() const { return m_cli.path; }
    QString cliVersion() const { return m_cli.version; }

    OperationQueue *queue() { return &m_queue; }
    CommandLog *commandLog() { return &m_log; }
    PackageListModel *searchModel() { return &m_searchModel; }
    PackageListModel *installedModel() { return &m_installedModel; }
    PackageListModel *outdatedModel() { return &m_outdatedModel; }
    QVariantList actions() const;

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void redetectCli();

    // Disk cache (installed/outdated lists + package details): the UI paints
    // instantly from the last known state, then live refreshes overwrite it.
    Q_INVOKABLE void clearCache();
    Q_INVOKABLE QString cacheSizeText() const;

    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void requestInfo(const QString &packageId, const QString &kind);
    Q_INVOKABLE void refreshInstalled();
    Q_INVOKABLE void refreshOutdated();

    Q_INVOKABLE void install(const QString &packageId, const QString &kind);
    Q_INVOKABLE void uninstall(const QString &packageId, const QString &kind);
    Q_INVOKABLE void upgrade(const QString &packageId, const QString &kind);
    Q_INVOKABLE void upgradeAll();
    Q_INVOKABLE bool canPin(const QString &packageId, const QString &kind) const;
    Q_INVOKABLE void pin(const QString &packageId, const QString &kind);
    Q_INVOKABLE void unpin(const QString &packageId, const QString &kind);

    Q_INVOKABLE void runAction(const QString &actionId, const QString &packageId);
    Q_INVOKABLE QString actionCommandPreview(const QString &actionId) const;
    Q_INVOKABLE bool hasAction(const QString &actionId) const;
    // Runs an action silently and delivers its stdout via actionOutputReady —
    // for views that render command output (dependencies, taps, ...).
    Q_INVOKABLE void fetchActionOutput(const QString &actionId, const QString &packageId);

signals:
    void cliChanged();
    void terminalOutput(const QString &line, bool isStdErr);
    void commandStarted(const QString &commandLine);
    void commandFinished(int exitCode);
    void infoReady(const QVariantMap &package);
    void toast(const QString &message, bool isError);
    void actionOutputReady(const QString &actionId, const QString &packageId,
                           const QString &stdOut, bool ok);

private:
    void enqueueMutation(const QString &kind, const QString &packageId,
                         const CliCommand &command, const QString &successMessage);
    void refreshAll();
    void annotateInstalled(QList<Package> &packages) const;

    QString cacheDir() const;
    void saveListCache(const QString &name, const QList<Package> &packages) const;
    QList<Package> loadListCache(const QString &name) const;
    void loadDetailsCache();
    void saveDetailsCache() const;

    PackageManagerAdapter *m_adapter;
    ProcessRunner m_runner;
    CommandLog m_log;
    OperationQueue m_queue;
    PackageListModel m_searchModel;
    PackageListModel m_installedModel;
    PackageListModel m_outdatedModel;
    QHash<QString, Package> m_installedIndex;
    QHash<QString, QVariantMap> m_detailsCache;
    bool m_detailsCacheLoaded = false;
    CliInfo m_cli;
};

} // namespace yas
