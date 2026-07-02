#include "thememanager.h"

#include <QGuiApplication>
#include <QStyleHints>

namespace yas {

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
    , m_mode(m_settings.value(QStringLiteral("ui/themeMode"),
                              QStringLiteral("auto")).toString())
{
    if (m_mode != QStringLiteral("light") && m_mode != QStringLiteral("dark"))
        m_mode = QStringLiteral("auto");

    // Follow the OS live while in auto mode (user flips system appearance).
    connect(QGuiApplication::styleHints(), &QStyleHints::colorSchemeChanged, this,
            [this] {
                if (m_mode == QStringLiteral("auto"))
                    emit darkModeChanged();
            });
}

bool ThemeManager::systemPrefersDark() const
{
    // Unknown (some Linux setups) falls back to dark — the suite's default.
    return QGuiApplication::styleHints()->colorScheme() != Qt::ColorScheme::Light;
}

bool ThemeManager::darkMode() const
{
    if (m_mode == QStringLiteral("light"))
        return false;
    if (m_mode == QStringLiteral("dark"))
        return true;
    return systemPrefersDark();
}

void ThemeManager::setThemeMode(const QString &mode)
{
    if (m_mode == mode)
        return;
    m_mode = mode;
    m_settings.setValue(QStringLiteral("ui/themeMode"), mode);
    emit themeModeChanged();
    emit darkModeChanged();
}

void ThemeManager::cycleThemeMode()
{
    if (m_mode == QStringLiteral("auto"))
        setThemeMode(QStringLiteral("light"));
    else if (m_mode == QStringLiteral("light"))
        setThemeMode(QStringLiteral("dark"));
    else
        setThemeMode(QStringLiteral("auto"));
}

} // namespace yas
