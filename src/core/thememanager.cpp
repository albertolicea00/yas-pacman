#include "thememanager.h"

#include <QFile>
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
    m_terminalAutoExpand =
        m_settings.value(QStringLiteral("ui/terminalAutoExpand"), false).toBool();
    m_autoLoadDetails =
        m_settings.value(QStringLiteral("ui/autoLoadDetails"), true).toBool();
    m_confirmDestructive =
        m_settings.value(QStringLiteral("ui/confirmDestructive"), true).toBool();
    m_showDescriptions =
        m_settings.value(QStringLiteral("ui/showDescriptions"), true).toBool();
    m_showFeatured =
        m_settings.value(QStringLiteral("ui/showFeatured"), true).toBool();
    m_featuredUrl = m_settings.value(QStringLiteral("ui/featuredUrl")).toString();
    m_uiScale = m_settings.value(QStringLiteral("ui/scale"), 1.0).toDouble();
    if (m_uiScale < 0.8 || m_uiScale > 2.0)
        m_uiScale = 1.0;
    m_railExpanded = m_settings.value(QStringLiteral("ui/railExpanded"), true).toBool();
    m_defaultKind = m_settings.value(QStringLiteral("ui/defaultKind")).toString();

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

void ThemeManager::setTerminalAutoExpand(bool expand)
{
    if (m_terminalAutoExpand == expand)
        return;
    m_terminalAutoExpand = expand;
    m_settings.setValue(QStringLiteral("ui/terminalAutoExpand"), expand);
    emit terminalAutoExpandChanged();
}

void ThemeManager::setAutoLoadDetails(bool autoLoad)
{
    if (m_autoLoadDetails == autoLoad)
        return;
    m_autoLoadDetails = autoLoad;
    m_settings.setValue(QStringLiteral("ui/autoLoadDetails"), autoLoad);
    emit autoLoadDetailsChanged();
}

void ThemeManager::setConfirmDestructive(bool confirm)
{
    if (m_confirmDestructive == confirm)
        return;
    m_confirmDestructive = confirm;
    m_settings.setValue(QStringLiteral("ui/confirmDestructive"), confirm);
    emit confirmDestructiveChanged();
}

QString ThemeManager::bundledFeaturedJson() const
{
    QFile file(QStringLiteral(":/yas/featured.json"));
    if (!file.open(QIODevice::ReadOnly))
        return QStringLiteral("{}");
    return QString::fromUtf8(file.readAll());
}

void ThemeManager::setShowDescriptions(bool show)
{
    if (m_showDescriptions == show)
        return;
    m_showDescriptions = show;
    m_settings.setValue(QStringLiteral("ui/showDescriptions"), show);
    emit showDescriptionsChanged();
}

void ThemeManager::setShowFeatured(bool show)
{
    if (m_showFeatured == show)
        return;
    m_showFeatured = show;
    m_settings.setValue(QStringLiteral("ui/showFeatured"), show);
    emit showFeaturedChanged();
}

void ThemeManager::setFeaturedUrl(const QString &url)
{
    if (m_featuredUrl == url)
        return;
    m_featuredUrl = url;
    m_settings.setValue(QStringLiteral("ui/featuredUrl"), url);
    emit featuredUrlChanged();
}

void ThemeManager::setUiScale(double scale)
{
    if (qFuzzyCompare(m_uiScale, scale))
        return;
    m_uiScale = scale;
    m_settings.setValue(QStringLiteral("ui/scale"), scale);
    emit uiScaleChanged();
}

void ThemeManager::setRailExpanded(bool expanded)
{
    if (m_railExpanded == expanded)
        return;
    m_railExpanded = expanded;
    m_settings.setValue(QStringLiteral("ui/railExpanded"), expanded);
    emit railExpandedChanged();
}

void ThemeManager::setDefaultKind(const QString &kind)
{
    if (m_defaultKind == kind)
        return;
    m_defaultKind = kind;
    m_settings.setValue(QStringLiteral("ui/defaultKind"), kind);
    emit defaultKindChanged();
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
