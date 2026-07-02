#include "thememanager.h"

namespace yas {

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
    , m_darkMode(m_settings.value(QStringLiteral("ui/darkMode"), true).toBool())
{
}

void ThemeManager::setDarkMode(bool dark)
{
    if (m_darkMode == dark)
        return;
    m_darkMode = dark;
    m_settings.setValue(QStringLiteral("ui/darkMode"), dark);
    emit darkModeChanged();
}

} // namespace yas
