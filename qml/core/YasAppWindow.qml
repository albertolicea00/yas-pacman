import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Yas.Core

// Application shell shared by every YAS store. Each app instantiates this
// with its brand accent, tag and name; requires the `App` context property.
ApplicationWindow {
    id: window

    property string appName: "Yet Another Store"
    property color accent: Theme.accent
    property string tag: "YAS"
    property url iconSource: ""
    // Per-app manager-specific views appended after the 6 base views.
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

    // ---- Sidebar ------------------------------------------------------
    Rectangle {
        id: sidebar
        width: Theme.sidebarWidth
        anchors.top: parent.top
        anchors.bottom: terminal.top
        color: Theme.surface

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Row {
                spacing: 8
                padding: 6
                Image {
                    visible: window.iconSource.toString().length > 0
                    source: window.iconSource
                    width: 28; height: 28
                    fillMode: Image.PreserveAspectFit
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "YAS"
                        color: Theme.textPrimary
                        font.family: Theme.headingFont
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                    TagBadge { text: window.tag }
                }
            }

            Item { width: 1; height: 12 }

            Repeater {
                model: window.baseNav.concat(window.extraViews)
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: parent.width
                    height: 38
                    radius: Theme.radius
                    color: stack.currentIndex === index ? Theme.accentSubtle
                           : navHover.hovered ? Theme.surfaceAlt : "transparent"

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        Text {
                            text: modelData.icon
                            color: stack.currentIndex === index ? Theme.accent : Theme.textSecondary
                            font.pixelSize: 14
                        }
                        Text {
                            text: modelData.label
                            color: stack.currentIndex === index ? Theme.textPrimary : Theme.textSecondary
                            font.family: Theme.uiFont
                            font.pixelSize: 13
                            font.weight: stack.currentIndex === index ? Font.DemiBold : Font.Normal
                        }
                        Rectangle {
                            visible: index === 2 && App.outdatedModel.count > 0
                            anchors.verticalCenter: parent.verticalCenter
                            width: badge.implicitWidth + 10; height: 16; radius: 8
                            color: Theme.danger
                            Text {
                                id: badge
                                anchors.centerIn: parent
                                text: App.outdatedModel.count
                                color: "#141420"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                        }
                    }
                    HoverHandler { id: navHover }
                    TapHandler { onTapped: stack.currentIndex = index }
                }
            }
        }
    }

    // ---- CLI-missing banner -------------------------------------------
    Rectangle {
        id: banner
        visible: !App.cliAvailable
        anchors.top: parent.top
        anchors.left: sidebar.right
        anchors.right: parent.right
        height: visible ? 44 : 0
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

    // ---- Main content --------------------------------------------------
    StackLayout {
        id: stack
        anchors.top: banner.bottom
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.bottom: terminal.top
        anchors.margins: 16

        ExplorerView {}
        InstalledView {}
        UpdatesView {}
        ActionsView {}
        HistoryView {}
        SettingsView {}

        Repeater {
            model: window.extraViews
            delegate: Loader {
                required property var modelData
                source: modelData.source
            }
        }
    }

    // ---- Terminal panel --------------------------------------------------
    TerminalView {
        id: terminal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    // ---- Toasts ---------------------------------------------------------
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
            color: "#141420"
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
