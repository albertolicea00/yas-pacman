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
    Q_PROPERTY(double uiScale READ uiScale WRITE setUiScale NOTIFY uiScaleChanged)
    Q_PROPERTY(bool railExpanded READ railExpanded WRITE setRailExpanded NOTIFY railExpandedChanged)
    Q_PROPERTY(QString defaultKind READ defaultKind WRITE setDefaultKind NOTIFY defaultKindChanged)
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

    // Text/element size multiplier (1.0 normal, 1.15 large, 1.3 extra).
    double uiScale() const { return m_uiScale; }
    void setUiScale(double scale);

    // Sidebar rail expanded (icon + text) vs compact (icon only).
    bool railExpanded() const { return m_railExpanded; }
    void setRailExpanded(bool expanded);

    // Kind filter applied to Installed by default ("" = all).
    QString defaultKind() const { return m_defaultKind; }
    void setDefaultKind(const QString &kind);

signals:
    void themeModeChanged();
    void darkModeChanged();
    void terminalAutoExpandChanged();
    void autoLoadDetailsChanged();
    void confirmDestructiveChanged();
    void showDescriptionsChanged();
    void showFeaturedChanged();
    void featuredUrlChanged();
    void uiScaleChanged();
    void railExpandedChanged();
    void defaultKindChanged();

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
    double m_uiScale = 1.0;
    bool m_railExpanded = true;
    QString m_defaultKind;
};

} // namespace yas
