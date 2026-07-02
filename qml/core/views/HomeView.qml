import QtQuick
import QtQuick.Controls.Basic
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

    component StatTile: Rectangle {
        property string value: ""
        property string label: ""
        property color tint: Theme.accent
        property int targetIndex: -1

        width: Theme.fs(128)
        height: Theme.fs(84)
        radius: Theme.radius
        color: tileHover.hovered && targetIndex >= 0 ? Theme.surfaceAlt : Theme.surface

        Column {
            id: tileColumn
            anchors.centerIn: parent
            spacing: 2
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: value
                color: tint
                font.family: Theme.headingFont
                font.pixelSize: Theme.fs(26)
                font.weight: Font.Bold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(11)
            }
        }
        HoverHandler { id: tileHover; cursorShape: targetIndex >= 0 ? Qt.PointingHandCursor : Qt.ArrowCursor }
        TapHandler { onTapped: if (targetIndex >= 0) root.navigate(targetIndex) }
    }

    Column {
        id: content
        width: root.width
        spacing: 14

        // Search — sends you straight to Explore with results.
        SearchBar {
            width: parent.width
            placeholder: qsTr("Search %1 packages…").arg(App.managerName)
            onAccepted: query => { if (query.trim().length > 0) root.searchRequested(query.trim()) }
        }

        // Stats — centered grid
        Grid {
            id: statsGrid
            readonly property int tileSlot: Theme.fs(128) + 10
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.max(1, Math.floor(content.width / tileSlot))
            spacing: 10

            StatTile {
                value: App.installedModel.totalCount
                label: qsTr("installed")
                targetIndex: 2
            }
            Repeater {
                model: App.installedModel.kindSummary.length > 1
                       ? App.installedModel.kindSummary : []
                delegate: StatTile {
                    required property var modelData
                    value: modelData.count
                    label: modelData.kind.length > 0 ? modelData.kind : qsTr("other")
                    tint: Theme.textPrimary
                    targetIndex: 2
                }
            }
            StatTile {
                value: App.outdatedModel.count
                label: qsTr("upgradable")
                tint: App.outdatedModel.count > 0 ? Theme.danger : Theme.success
                targetIndex: 3
            }
            StatTile {
                visible: App.installedModel.pinnedCount > 0
                value: App.installedModel.pinnedCount
                label: qsTr("pinned")
                tint: Theme.textPrimary
                targetIndex: 2
            }
            StatTile {
                visible: root.sourcesCount >= 0
                value: root.sourcesCount
                label: qsTr("taps")
                tint: Theme.textPrimary
            }
        }

        // Promo: curated storefront in Explore.
        Rectangle {
            width: parent.width
            height: Theme.fs(72)
            radius: Theme.radius
            color: Theme.accentSubtle
            border.color: Theme.accent

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: promoBtn.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                Text {
                    width: parent.width
                    text: qsTr("Explore the author's selection")
                    color: Theme.textPrimary
                    font.family: Theme.headingFont
                    font.pixelSize: Theme.fs(15)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: qsTr("A curated set of %1 packages, ready to install in one click").arg(App.managerName)
                    color: Theme.textSecondary
                    font.family: Theme.uiFont
                    font.pixelSize: Theme.fs(12)
                    elide: Text.ElideRight
                }
            }
            AccentButton {
                id: promoBtn
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Explore")
                onClicked: { App.search(""); root.navigate(1) }
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
