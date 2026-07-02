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
public:
    explicit ThemeManager(QObject *parent = nullptr);

    QString themeMode() const { return m_mode; }
    void setThemeMode(const QString &mode); // "auto" | "light" | "dark"

    bool darkMode() const;

    // auto -> light -> dark -> auto
    Q_INVOKABLE void cycleThemeMode();

signals:
    void themeModeChanged();
    void darkModeChanged();

private:
    bool systemPrefersDark() const;

    QSettings m_settings;
    QString m_mode;
};

} // namespace yas
