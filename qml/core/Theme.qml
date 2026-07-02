pragma Singleton
import QtQuick

// Design tokens for the whole YAS suite (see each repo's DESIGN.md).
// `accent` and `tag` are set at startup by the store app via YasAppWindow.
QtObject {
    // Suite background palette — neutral OS-style dark grays.
    property color base: "#212826"
    property color surface: "#2A302E"
    property color surfaceAlt: "#2D3130"
    property color border: "#393C3B"
    property color terminalBase: "#1A201E"
    property color accent: "#FFC107"
    property color accentSubtle: Qt.rgba(accent.r, accent.g, accent.b, 0.10)
    property color textPrimary: "#F8F8F2"
    property color textSecondary: "#ACADAD"
    property color danger: "#F7768E"
    property color success: "#9ECE6A"
    property string tag: "YAS"

    // Platform flavor: corner rounding follows the design language of the OS
    // the app runs on (macOS soft, Windows Fluent-square, Linux in-between).
    readonly property string os: Qt.platform.os
    property int radius: os === "osx" ? 10 : os === "windows" ? 4 : 6
    property int spacing: 12
    property int sidebarWidth: 200

    property string headingFont: "Outfit"
    property string uiFont: "Inter"
    property string monoFont: "JetBrains Mono"
}
