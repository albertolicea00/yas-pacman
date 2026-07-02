pragma Singleton
import QtQuick

// Design tokens for the whole YAS suite (see each repo's DESIGN.md).
// `accent`/`tag` come from the store app; `dark` is driven by YasManager.
QtObject {
    property bool dark: true

    // Backgrounds — OS-neutral grays, one palette per mode.
    property color base: dark ? "#222629" : "#F4F5F6"
    property color surface: dark ? "#2D3032" : "#FFFFFF"
    property color rail: dark ? "#262B2E" : "#EDEFF0"
    property color surfaceAlt: dark ? "#383B3E" : "#EAECED"
    property color border: dark ? "#393C3B" : "#D8DADC"
    property color terminalBase: dark ? "#1A201E" : "#E9EBEC"

    property color accent: "#FFC107"
    property color accentSubtle: Qt.rgba(accent.r, accent.g, accent.b, dark ? 0.12 : 0.15)
    property color textPrimary: dark ? "#F8F8F2" : "#1D2023"
    property color textSecondary: dark ? "#ACADAD" : "#5C6166"
    property color danger: dark ? "#F7768E" : "#C4304B"
    property color success: dark ? "#9ECE6A" : "#3E7B27"
    property string tag: "YAS"

    // UI scale (Settings): multiplies font sizes and key element heights.
    property real scale: 1.0
    function fs(size) { return Math.round(size * scale) }

    // Platform flavor: corner rounding follows the design language of the OS
    // the app runs on (macOS soft, Windows Fluent-square, Linux in-between).
    readonly property string os: Qt.platform.os
    property int radius: os === "osx" ? 10 : os === "windows" ? 4 : 6
    property int spacing: 12
    property int railWidth: Math.round(56 * scale)

    property string headingFont: "Outfit"
    property string uiFont: "Inter"
    property string monoFont: "JetBrains Mono"
}
