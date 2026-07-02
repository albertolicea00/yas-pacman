pragma Singleton
import QtQuick

QtObject {
    id: theme

    property bool isDark: false

    // Light mode
    property color bgPrimary: isDark ? "#1e1e1e" : "#ffffff"
    property color bgSecondary: isDark ? "#2d2d2d" : "#f5f5f5"
    property color bgTertiary: isDark ? "#3d3d3d" : "#efefef"
    property color textPrimary: isDark ? "#ffffff" : "#000000"
    property color textSecondary: isDark ? "#cccccc" : "#555555"
    property color borderColor: isDark ? "#444444" : "#d0d0d0"
    property color accentColor: "#0078d4"
    property color hoverBg: isDark ? "#3d3d3d" : "#f0f0f0"
    property color panelBg: isDark ? "#252525" : "#ffffff"

    // Status colors
    property color statusClean: isDark ? "#8ae234" : "#155724"
    property color statusDirty: isDark ? "#ffff00" : "#856404"
    property color statusCleanBg: isDark ? "#1e4620" : "#d4edda"
    property color statusDirtyBg: isDark ? "#3d3d00" : "#fff3cd"

    // Fonts
    readonly property string fontFamily: "Segoe UI, -apple-system, BlinkMacSystemFont"
    readonly property int fontSize: 13
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeSmall: 12

    function toggleDarkMode() {
        isDark = !isDark
    }
}
