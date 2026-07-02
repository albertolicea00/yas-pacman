import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

Flickable {
    id: root
    contentHeight: content.height + 20
    clip: true
    ScrollBar.vertical: ScrollBar {}

    component SectionCard: Rectangle {
        default property alias body: inner.data
        property string heading: ""
        width: content.width
        implicitHeight: inner.implicitHeight + 46
        radius: Theme.radius
        color: Theme.surface

        Text {
            id: headingText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 14
            text: parent.heading
            color: Theme.textPrimary
            font.family: Theme.uiFont
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
        Column {
            id: inner
            anchors.top: headingText.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            anchors.topMargin: 10
            spacing: 8
        }
    }

    Column {
        id: content
        width: root.width
        spacing: 12

        Text {
            text: qsTr("Settings")
            color: Theme.textPrimary
            font.family: Theme.headingFont
            font.pixelSize: 24
            font.weight: Font.Bold
        }

        SectionCard {
            heading: qsTr("Appearance")

            Row {
                spacing: 8
                Repeater {
                    model: [
                        { mode: "auto",  label: qsTr("Auto"),  icon: "◐" },
                        { mode: "light", label: qsTr("Light"), icon: "☀" },
                        { mode: "dark",  label: qsTr("Dark"),  icon: "☾" },
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: YasManager.themeMode === modelData.mode
                        width: modeLabel.implicitWidth + 30
                        height: 30
                        radius: Theme.radius
                        color: active ? Theme.accentSubtle : Theme.base
                        border.color: active ? Theme.accent : Theme.border

                        Text {
                            id: modeLabel
                            anchors.centerIn: parent
                            text: modelData.icon + "  " + modelData.label
                            color: parent.active ? Theme.accent : Theme.textSecondary
                            font.family: Theme.uiFont
                            font.pixelSize: 12
                        }
                        TapHandler { onTapped: YasManager.themeMode = modelData.mode }
                    }
                }
            }
            Text {
                text: qsTr("Auto follows the system appearance")
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: 11
            }
        }

        SectionCard {
            heading: qsTr("Packages")

            ThemedSwitch {
                label: qsTr("Load package details automatically")
                description: qsTr("Fetch full metadata when a package is selected")
                checked: YasManager.autoLoadDetails
                onToggled: checked => YasManager.autoLoadDetails = checked
            }
            ThemedSwitch {
                label: qsTr("Confirm uninstall and upgrade")
                description: qsTr("Ask before running operations that modify the system")
                checked: YasManager.confirmDestructive
                onToggled: checked => YasManager.confirmDestructive = checked
            }
            ThemedSwitch {
                label: qsTr("Show package descriptions")
                description: qsTr("Second line in list rows")
                checked: YasManager.showDescriptions
                onToggled: checked => YasManager.showDescriptions = checked
            }
        }

        SectionCard {
            heading: qsTr("Discoverability")

            ThemedSwitch {
                label: qsTr("Show featured packages in Explore")
                description: qsTr("Store-like categories before your first search")
                checked: YasManager.showFeatured
                onToggled: checked => YasManager.showFeatured = checked
            }
            Column {
                width: parent.width
                spacing: 4
                visible: YasManager.showFeatured
                Text {
                    text: qsTr("Featured source URL (empty = bundled defaults)")
                    color: Theme.textSecondary
                    font.family: Theme.uiFont
                    font.pixelSize: 11
                }
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.radius
                    color: Theme.base
                    border.color: urlField.activeFocus ? Theme.accent : Theme.border
                    TextField {
                        id: urlField
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        text: YasManager.featuredUrl
                        placeholderText: qsTr("https://…/featured.json")
                        placeholderTextColor: Theme.textSecondary
                        color: Theme.textPrimary
                        font.family: Theme.monoFont
                        font.pixelSize: 12
                        background: null
                        onEditingFinished: YasManager.featuredUrl = text
                    }
                }
            }
        }

        SectionCard {
            heading: qsTr("Terminal")

            ThemedSwitch {
                label: qsTr("Expand terminal when a command runs")
                description: qsTr("Automatically open the output panel on activity")
                checked: YasManager.terminalAutoExpand
                onToggled: checked => YasManager.terminalAutoExpand = checked
            }
            Row {
                spacing: 4
                IconButton {
                    icon: "⌫"
                    label: qsTr("Clear command history (%1)").arg(App.commandLog.count)
                    tint: Theme.danger
                    onClicked: App.commandLog.clear()
                }
            }
        }

        SectionCard {
            heading: qsTr("CLI backend")

            Text {
                width: parent.width
                text: App.cliAvailable
                      ? qsTr("%1 detected at %2").arg(App.managerName).arg(App.cliPath)
                      : qsTr("%1 CLI not found — install it and hit Re-detect")
                            .arg(App.managerName)
                color: App.cliAvailable ? Theme.success : Theme.danger
                font.family: Theme.monoFont
                font.pixelSize: 12
                wrapMode: Text.WrapAnywhere
            }
            Text {
                visible: App.cliAvailable
                text: App.cliVersion
                color: Theme.textSecondary
                font.family: Theme.monoFont
                font.pixelSize: 12
            }
            Row {
                spacing: 4
                IconButton {
                    icon: "↻"
                    label: qsTr("Re-detect")
                    onClicked: { App.redetectCli(); if (App.cliAvailable) App.initialize() }
                }
            }
        }
    }
}
