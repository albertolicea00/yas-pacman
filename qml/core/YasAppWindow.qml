import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Yas.Core

// Teams-style application shell shared by every YAS store: a slim icon rail,
// then each section lays out its own list + detail panels. Requires the
// `App` and `YasManager` context properties.
ApplicationWindow {
    id: window

    property string appName: "Yet Another Store"
    property color accent: Theme.accent
    property string tag: "YAS"
    property url iconSource: ""
    // Per-app manager-specific views appended to the rail.
    // Each entry: { label: string, icon: string, source: url of a .qml }
    property var extraViews: []

    readonly property var baseNav: [
        { label: qsTr("Explore"),   icon: "⌕" },
        { label: qsTr("Installed"), icon: "▤" },
        { label: qsTr("Updates"),   icon: "↺" },
        { label: qsTr("Actions"),   icon: "⚙" },
        { label: qsTr("History"),   icon: "≡" },
        { label: qsTr("Settings"),  icon: "✦" },
    ]

    width: 1180
    height: 760
    minimumWidth: 900
    minimumHeight: 560
    visible: true
    title: appName
    color: Theme.base

    Component.onCompleted: {
        Theme.accent = accent
        Theme.tag = tag
        if (App.cliAvailable)
            App.initialize()
    }

    // Persisted light/dark mode (YasManager wraps QSettings).
    Binding {
        target: Theme
        property: "dark"
        value: YasManager.darkMode
    }

    // ---- Icon rail (Teams-style) -----------------------------------------
    Rectangle {
        id: rail
        width: Theme.railWidth
        anchors.top: parent.top
        anchors.bottom: terminal.top
        color: Theme.surface

        Rectangle { // separator against content
            anchors.right: parent.right
            width: 1
            height: parent.height
            color: Theme.border
        }

        Column {
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            Image {
                visible: window.iconSource.toString().length > 0
                source: window.iconSource
                width: 30; height: 30
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TagBadge {
                visible: window.iconSource.toString().length === 0
                text: window.tag.substring(0, 4)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { width: 1; height: 10 }

            Repeater {
                model: window.baseNav.concat(window.extraViews)
                delegate: Item {
                    required property var modelData
                    required property int index
                    width: Theme.railWidth
                    height: 52

                    Rectangle { // active indicator
                        visible: stack.currentIndex === index
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3; height: 26; radius: 1.5
                        color: Theme.accent
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 1
                        Text {
                            text: modelData.icon
                            font.pixelSize: 17
                            color: stack.currentIndex === index ? Theme.accent
                                                                : Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: modelData.label
                            font.family: Theme.uiFont
                            font.pixelSize: 9
                            color: stack.currentIndex === index ? Theme.textPrimary
                                                                : Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Rectangle { // updates badge
                        visible: index === 2 && App.outdatedModel.count > 0
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        width: Math.max(16, updatesBadge.implicitWidth + 8)
                        height: 16; radius: 8
                        color: Theme.danger
                        Text {
                            id: updatesBadge
                            anchors.centerIn: parent
                            text: App.outdatedModel.count
                            color: "#FFFFFF"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: Theme.radius
                        z: -1
                        color: navHover.hovered && stack.currentIndex !== index
                               ? Theme.surfaceAlt : "transparent"
                    }
                    HoverHandler { id: navHover }
                    TapHandler { onTapped: stack.currentIndex = index }
                }
            }
        }

        // Light/dark toggle pinned to the bottom of the rail.
        Item {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.railWidth
            height: 40

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: Theme.radius
                color: themeHover.hovered ? Theme.surfaceAlt : "transparent"
            }
            Text {
                anchors.centerIn: parent
                text: YasManager.themeMode === "auto" ? "◐"
                      : YasManager.themeMode === "light" ? "☀" : "☾"
                font.pixelSize: 16
                color: Theme.textSecondary
            }
            HoverHandler { id: themeHover }
            TapHandler { onTapped: YasManager.cycleThemeMode() }
            ToolTip.visible: themeHover.hovered
            ToolTip.text: YasManager.themeMode === "auto"
                          ? qsTr("Theme: auto (follows the system)")
                          : YasManager.themeMode === "light" ? qsTr("Theme: light")
                                                             : qsTr("Theme: dark")
            ToolTip.delay: 400
        }
    }

    // ---- CLI-missing banner -----------------------------------------------
    Rectangle {
        id: banner
        visible: !App.cliAvailable
        anchors.top: parent.top
        anchors.left: rail.right
        anchors.right: parent.right
        height: visible ? 40 : 0
        color: Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.15)

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: qsTr("%1 CLI not found. Install it and re-detect in Settings.")
                      .arg(App.managerName)
            color: Theme.danger
            font.family: Theme.uiFont
            font.pixelSize: 13
        }
    }

    // ---- Main content -------------------------------------------------------
    StackLayout {
        id: stack
        anchors.top: banner.bottom
        anchors.left: rail.right
        anchors.right: parent.right
        anchors.bottom: terminal.top

        // Package sections are flush (Teams panels); tool sections get padding.
        ExplorerView {}
        InstalledView {}
        UpdatesView {}
        Item { ActionsView { anchors.fill: parent; anchors.margins: 16 } }
        Item { HistoryView { anchors.fill: parent; anchors.margins: 16 } }
        Item { SettingsView { anchors.fill: parent; anchors.margins: 16 } }

        Repeater {
            model: window.extraViews
            delegate: Loader {
                required property var modelData
                source: modelData.source
            }
        }
    }

    // ---- Terminal panel -------------------------------------------------------
    TerminalView {
        id: terminal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    // ---- Toasts -----------------------------------------------------------------
    Rectangle {
        id: toastBox
        property bool isError: false
        visible: opacity > 0
        opacity: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: terminal.top
        anchors.bottomMargin: 16
        width: toastLabel.implicitWidth + 32
        height: 40
        radius: 20
        color: isError ? Theme.danger : Theme.success
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            id: toastLabel
            anchors.centerIn: parent
            color: "#FFFFFF"
            font.family: Theme.uiFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
        Timer {
            id: toastTimer
            interval: 3500
            onTriggered: toastBox.opacity = 0
        }
    }

    Connections {
        target: App
        function onToast(message, isError) {
            toastLabel.text = message
            toastBox.isError = isError
            toastBox.opacity = 1
            toastTimer.restart()
        }
    }
}
