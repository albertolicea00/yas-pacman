#pragma once

#include <QObject>
#include <QSettings>

namespace yas {

// Persists UI preferences (QSettings, per-app scope). Exposed to QML as the
// `YasManager` context property. Theme mode: "auto" follows the OS color
// scheme live; "light"/"dark" force one. Vendored per repo like the core.
class ThemeManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString themeMode READ themeMode WRITE setThemeMode NOTIFY themeModeChanged)
    Q_PROPERTY(bool darkMode READ darkMode NOTIFY darkModeChanged)
    Q_PROPERTY(bool terminalAutoExpand READ terminalAutoExpand
                   WRITE setTerminalAutoExpand NOTIFY terminalAutoExpandChanged)
    Q_PROPERTY(bool autoLoadDetails READ autoLoadDetails
                   WRITE setAutoLoadDetails NOTIFY autoLoadDetailsChanged)
    Q_PROPERTY(bool confirmDestructive READ confirmDestructive
                   WRITE setConfirmDestructive NOTIFY confirmDestructiveChanged)
    Q_PROPERTY(bool showDescriptions READ showDescriptions
                   WRITE setShowDescriptions NOTIFY showDescriptionsChanged)
    Q_PROPERTY(bool showFeatured READ showFeatured
                   WRITE setShowFeatured NOTIFY showFeaturedChanged)
    Q_PROPERTY(QString featuredUrl READ featuredUrl
                   WRITE setFeaturedUrl NOTIFY featuredUrlChanged)
public:
    explicit ThemeManager(QObject *parent = nullptr);

    QString themeMode() const { return m_mode; }
    void setThemeMode(const QString &mode); // "auto" | "light" | "dark"

    bool darkMode() const;

    // auto -> light -> dark -> auto
    Q_INVOKABLE void cycleThemeMode();

    // Contents of the bundled :/yas/featured.json mock (QML XHR cannot read
    // qrc). Remote featuredUrl is fetched from QML via XMLHttpRequest.
    Q_INVOKABLE QString bundledFeaturedJson() const;

    bool terminalAutoExpand() const { return m_terminalAutoExpand; }
    void setTerminalAutoExpand(bool expand);

    // Fetch full package details automatically when a row is selected.
    bool autoLoadDetails() const { return m_autoLoadDetails; }
    void setAutoLoadDetails(bool autoLoad);

    // Ask before uninstall/upgrade operations.
    bool confirmDestructive() const { return m_confirmDestructive; }
    void setConfirmDestructive(bool confirm);

    // Show package descriptions in list rows.
    bool showDescriptions() const { return m_showDescriptions; }
    void setShowDescriptions(bool show);

    // Storefront in Explore before searching. featuredUrl empty -> bundled
    // mock (:/yas/featured.json); later points to the yas-web API.
    bool showFeatured() const { return m_showFeatured; }
    void setShowFeatured(bool show);
    QString featuredUrl() const { return m_featuredUrl; }
    void setFeaturedUrl(const QString &url);

signals:
    void themeModeChanged();
    void darkModeChanged();
    void terminalAutoExpandChanged();
    void autoLoadDetailsChanged();
    void confirmDestructiveChanged();
    void showDescriptionsChanged();
    void showFeaturedChanged();
    void featuredUrlChanged();

private:
    bool systemPrefersDark() const;

    QSettings m_settings;
    QString m_mode;
    bool m_terminalAutoExpand = false;
    bool m_autoLoadDetails = true;
    bool m_confirmDestructive = true;
    bool m_showDescriptions = true;
    bool m_showFeatured = true;
    QString m_featuredUrl;
};

} // namespace yas
