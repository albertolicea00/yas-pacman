import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Yas.Core

// Teams-style application shell shared by every YAS store: a collapsible
// icon rail, then each section lays out its own panels. Requires the
// `App` and `YasManager` context properties.
ApplicationWindow {
    id: window

    property string appName: "Yet Another Store"
    property color accent: Theme.accent
    property string tag: "YAS"
    property url iconSource: ""
    // Kind filter seeded into Installed on first run (e.g. "cask" for brew);
    // the user's choice in Settings wins afterwards.
    property string defaultKind: ""
    // Per-app manager-specific views appended to the rail.
    // Each entry: { label: string, icon: string, source: url of a .qml }
    property var extraViews: []

    readonly property var baseNav: [
        { label: qsTr("Home"),      icon: "home" },
        { label: qsTr("Explore"),   icon: "search" },
        { label: qsTr("Installed"), icon: "box" },
        { label: qsTr("Updates"),   icon: "refresh" },
        { label: qsTr("Actions"),   icon: "tools" },
        { label: qsTr("Settings"),  icon: "settings" },
    ]
    readonly property int historyIndex: 6 + extraViews.length
    readonly property bool railOpen: YasManager.railExpanded

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
        if (defaultKind.length > 0 && YasManager.defaultKind.length === 0)
            YasManager.defaultKind = defaultKind
        if (App.cliAvailable)
            App.initialize()
    }

    Binding { target: Theme; property: "dark"; value: YasManager.darkMode }
    Binding { target: Theme; property: "scale"; value: YasManager.uiScale }

    // ---- Collapsible icon rail ---------------------------------------------
    Rectangle {
        id: rail
        width: window.railOpen ? Math.round(190 * Theme.scale) : Theme.railWidth
        anchors.top: parent.top
        anchors.bottom: terminal.top
        color: Theme.rail
        Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

        Rectangle { // separator against content
            anchors.right: parent.right
            width: 1
            height: parent.height
            color: Theme.border
        }

        Column {
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            // App icon + expand/collapse toggle.
            Item {
                width: parent.width
                height: 40

                Row {
                    visible: window.railOpen
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Image {
                        visible: window.iconSource.toString().length > 0
                        source: window.iconSource
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        textFormat: Text.StyledText
                        text: qsTr("YAS for") + " <font color=\"" + Theme.accent
                              + "\">" + window.tag + "</font>"
                        color: Theme.textPrimary
                        font.family: Theme.headingFont
                        font.pixelSize: Theme.fs(14)
                        font.weight: Font.Bold
                    }
                }

                Item {
                    width: Theme.railWidth
                    height: parent.height
                    anchors.right: parent.right

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: Theme.radius
                        color: toggleHover.hovered ? Theme.surfaceAlt : "transparent"
                    }
                    Text {
                        anchors.centerIn: parent
                        text: window.railOpen ? "«" : "»"
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fs(18)
                    }
                    HoverHandler { id: toggleHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: YasManager.railExpanded = !YasManager.railExpanded }
                    ToolTip.visible: toggleHover.hovered
                    ToolTip.text: window.railOpen ? qsTr("Collapse menu") : qsTr("Expand menu")
                    ToolTip.delay: 450
                }
            }

            Item { width: 1; height: 6 }

            Repeater {
                model: window.baseNav.concat(window.extraViews)
                delegate: Item {
                    required property var modelData
                    required property int index
                    width: parent.width
                    height: Math.round((window.railOpen ? 42 : 54) * Theme.scale)

                    Rectangle { // active indicator
                        visible: stack.currentIndex === index
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3; height: 24; radius: 1.5
                        color: Theme.accent
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: Theme.radius
                        color: navHover.hovered && stack.currentIndex !== index
                               ? Theme.surfaceAlt : "transparent"
                    }

                    // Expanded: icon beside text. Collapsed: big icon + tiny label.
                    Row {
                        visible: window.railOpen
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12
                        YasIcon {
                            name: modelData.icon
                            size: Theme.fs(20)
                            color: stack.currentIndex === index ? Theme.accent
                                                                : Theme.textSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.label
                            font.family: Theme.uiFont
                            font.pixelSize: Theme.fs(13)
                            font.weight: stack.currentIndex === index ? Font.DemiBold
                                                                      : Font.Normal
                            color: stack.currentIndex === index ? Theme.textPrimary
                                                                : Theme.textSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Column {
                        visible: !window.railOpen
                        anchors.centerIn: parent
                        spacing: 3
                        YasIcon {
                            name: modelData.icon
                            size: Theme.fs(22)
                            color: stack.currentIndex === index ? Theme.accent
                                                                : Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: modelData.label
                            font.family: Theme.uiFont
                            font.pixelSize: Theme.fs(9)
                            color: stack.currentIndex === index ? Theme.textPrimary
                                                                : Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Rectangle { // updates badge
                        visible: index === 3 && App.outdatedModel.count > 0
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
                            font.pixelSize: Theme.fs(9)
                            font.weight: Font.Bold
                        }
                    }

                    HoverHandler { id: navHover }
                    TapHandler { onTapped: stack.currentIndex = index }
                }
            }
        }
    }

    // ---- CLI-missing banner ---------------------------------------------------
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
            font.pixelSize: Theme.fs(13)
        }
    }

    // ---- Main content -----------------------------------------------------------
    StackLayout {
        id: stack
        anchors.top: banner.bottom
        anchors.left: rail.right
        anchors.right: parent.right
        anchors.bottom: terminal.top

        Rectangle {
            color: Theme.rail
            HomeView {
                anchors.fill: parent
                anchors.margins: 20
                onNavigate: stackIndex => stack.currentIndex =
                                (stackIndex === 99 ? window.historyIndex : stackIndex)
                onSearchRequested: query => {
                    App.search(query)
                    stack.currentIndex = 1
                }
            }
        }
        ExplorerView {}
        InstalledView {}
        UpdatesView {}
        Item { ActionsView { anchors.fill: parent; anchors.margins: 16 } }
        Item {
            SettingsView {
                anchors.fill: parent
                anchors.margins: 16
                onOpenHistory: stack.currentIndex = window.historyIndex
            }
        }

        Repeater {
            model: window.extraViews
            delegate: Loader {
                required property var modelData
                source: modelData.source
            }
        }

        // History: not in the rail — reached from Settings (and Home).
        Item {
            HistoryView {
                anchors.fill: parent
                anchors.margins: 16
                onBack: stack.currentIndex = 5
            }
        }
    }

    // ---- Terminal panel -----------------------------------------------------------
    TerminalView {
        id: terminal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    // ---- Toasts ----------------------------------------------------------------------
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
            font.pixelSize: Theme.fs(13)
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
