import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Yas.Core

// Home: search (jumps to Explore), stat tiles per package type, then the
// status cards (manager health + versions, toolbox, history).
Flickable {
    id: root
    signal navigate(int stackIndex) // 1 Explore · 2 Installed · 3 Updates · 4 Actions · 5 Settings · 99 History
    signal searchRequested(string query)

    contentHeight: content.height + 30
    clip: true
    ScrollBar.vertical: ScrollBar {}

    // Manager-specific extra stat: tap/bucket/remote count when the adapter
    // exposes a listing action (e.g. brew's "tap").
    property int sourcesCount: -1
    Component.onCompleted: if (App.hasAction("tap")) App.fetchActionOutput("tap", "")
    Connections {
        target: App
        function onActionOutputReady(actionId, packageId, stdOut, ok) {
            if (actionId === "tap" && ok)
                root.sourcesCount = stdOut.trim().length > 0
                                    ? stdOut.trim().split("\n").length : 0
        }
    }

    // Informative stat tile (not clickable): icon + big number + label.
    component StatTile: Rectangle {
        property string value: ""
        property string label: ""
        property string icon: ""
        property color tint: Theme.accent

        Layout.fillWidth: true
        Layout.preferredHeight: Theme.fs(96)
        radius: Theme.radius
        color: Theme.base

        Column {
            anchors.centerIn: parent
            spacing: 3
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: icon
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fs(18)
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: value
                    color: tint
                    font.family: Theme.headingFont
                    font.pixelSize: Theme.fs(28)
                    font.weight: Font.Bold
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(11)
            }
        }
    }

    Column {
        id: content
        width: root.width
        spacing: 14

        // Search — sends you straight to Explore with results.
        SearchBar {
            width: parent.width
            bg: Theme.base
            placeholder: qsTr("Search %1 packages…").arg(App.managerName)
            onAccepted: query => { if (query.trim().length > 0) root.searchRequested(query.trim()) }
        }

        // Stats — full width, informative only
        RowLayout {
            width: parent.width
            spacing: 10

            StatTile {
                icon: "▤"
                value: App.installedModel.totalCount
                label: qsTr("installed")
            }
            Repeater {
                model: App.installedModel.kindSummary.length > 1
                       ? App.installedModel.kindSummary : []
                delegate: StatTile {
                    required property var modelData
                    icon: "❒"
                    value: modelData.count
                    label: modelData.kind.length > 0 ? modelData.kind : qsTr("other")
                    tint: Theme.textPrimary
                }
            }
            StatTile {
                icon: "↺"
                value: App.outdatedModel.count
                label: qsTr("upgradable")
                tint: App.outdatedModel.count > 0 ? Theme.danger : Theme.success
            }
            StatTile {
                visible: App.installedModel.pinnedCount > 0
                icon: "⚑"
                value: App.installedModel.pinnedCount
                label: qsTr("pinned")
                tint: Theme.textPrimary
            }
            StatTile {
                visible: root.sourcesCount >= 0
                icon: "⑂"
                value: root.sourcesCount
                label: qsTr("taps")
                tint: Theme.textPrimary
            }
        }

        // Promo: curated storefront in Explore (centered).
        Rectangle {
            width: parent.width
            height: promoColumn.implicitHeight + 32
            radius: Theme.radius
            color: Theme.accentSubtle
            border.color: Theme.accent

            Column {
                id: promoColumn
                anchors.centerIn: parent
                width: parent.width - 40
                spacing: 8
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Explore the author's selection")
                    color: Theme.textPrimary
                    font.family: Theme.headingFont
                    font.pixelSize: Theme.fs(16)
                    font.weight: Font.DemiBold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width, implicitWidth)
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("A curated set of %1 packages, ready to install in one click").arg(App.managerName)
                    color: Theme.textSecondary
                    font.family: Theme.uiFont
                    font.pixelSize: Theme.fs(12)
                    wrapMode: Text.WordWrap
                }
                AccentButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Explore")
                    onClicked: { App.search(""); root.navigate(1) }
                }
            }
        }

        // Status cards
        SummaryCard {
            icon: App.outdatedModel.count > 0 ? "↑" : "✓"
            title: App.outdatedModel.count > 0
                   ? qsTr("%1 package(s) can be upgraded").arg(App.outdatedModel.count)
                   : qsTr("Everything is up to date")
            subtitle: App.outdatedModel.count > 0
                      ? qsTr("Review them in Updates before upgrading")
                      : qsTr("No pending updates were found on the last check")
            actions: [
                AccentButton {
                    subtle: true
                    text: qsTr("Check for updates…")
                    onClicked: App.refreshOutdated()
                },
                AccentButton {
                    visible: App.outdatedModel.count > 0
                    text: qsTr("View")
                    onClicked: root.navigate(3)
                }
            ]
        }

        SummaryCard {
            icon: App.cliAvailable ? "⚡" : "⚠"
            title: App.cliAvailable
                   ? qsTr("%1 is ready").arg(App.managerName)
                   : qsTr("%1 CLI not found").arg(App.managerName)
            subtitle: App.cliAvailable
                      ? App.cliVersion + "\n"
                        + qsTr("This app: v%1").arg(Qt.application.version)
                      : qsTr("Install the CLI and re-detect it in Settings")
            actions: [
                AccentButton {
                    subtle: true
                    text: App.cliAvailable ? qsTr("Settings") : qsTr("Re-detect")
                    onClicked: App.cliAvailable ? root.navigate(5)
                                                : (App.redetectCli(),
                                                   App.cliAvailable && App.initialize())
                }
            ]
        }

        SummaryCard {
            icon: "⚙"
            title: qsTr("Toolbox")
            subtitle: qsTr("Every %1 maintenance command — diagnostics, cache cleanup, dependencies — in one place").arg(App.managerName)
            actions: [
                AccentButton {
                    subtle: true
                    text: qsTr("Open actions")
                    onClicked: root.navigate(4)
                }
            ]
        }

        SummaryCard {
            icon: "≡"
            title: qsTr("%1 command(s) in history").arg(App.commandLog.count)
            subtitle: qsTr("Every CLI command the app ran, ready to copy and learn from")
            actions: [
                AccentButton {
                    subtle: true
                    text: qsTr("View history")
                    onClicked: root.navigate(99)
                }
            ]
        }
    }
}
