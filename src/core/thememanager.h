#pragma once

#include <QObject>
#include <QSettings>

namespace yas {

// Persists UI preferences (QSettings, per-app scope). Exposed to QML as the
// `YasManager` context property; YasAppWindow binds Theme.dark to darkMode.
// Vendored per repo like the rest of the core — no shared package.
class ThemeManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)
public:
    explicit ThemeManager(QObject *parent = nullptr);

    bool darkMode() const { return m_darkMode; }
    void setDarkMode(bool dark);

    Q_INVOKABLE void toggleDarkMode() { setDarkMode(!m_darkMode); }

signals:
    void darkModeChanged();

private:
    QSettings m_settings;
    bool m_darkMode = true;
};

} // namespace yas
