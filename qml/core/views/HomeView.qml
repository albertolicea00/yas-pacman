import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Status summary (Applite-style): update state, installed breakdown, pins,
// CLI health and recent activity — one card each, with quick actions.
Flickable {
    id: root
    signal navigate(int stackIndex) // 1 Explore · 2 Installed · 3 Updates · 4 Actions · 5 Settings · 99 History

    contentHeight: content.height
    clip: true
    ScrollBar.vertical: ScrollBar {}

    function kindLine() {
        const parts = []
        const summary = App.installedModel.kindSummary
        for (let i = 0; i < summary.length; ++i) {
            const entry = summary[i]
            parts.push(entry.count + " " + (entry.kind.length > 0 ? entry.kind
                                                                  : qsTr("package(s)")))
        }
        return parts.join("  ·  ")
    }

    Column {
        id: content
        width: root.width
        spacing: 10

        Text {
            text: qsTr("%1 Status").arg(App.managerName)
            color: Theme.textPrimary
            font.family: Theme.headingFont
            font.pixelSize: Theme.fs(24)
            font.weight: Font.Bold
        }

        Item { width: 1; height: 2 }

        SummaryCard {
            icon: App.outdatedModel.count > 0 ? "↑" : "✓"
            title: App.outdatedModel.count > 0
                   ? qsTr("%1 package(s) can be upgraded").arg(App.outdatedModel.count)
                   : qsTr("Everything is up to date")
            subtitle: App.outdatedModel.count > 0
                      ? qsTr("Review them in the Updates section before upgrading")
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
            icon: "▤"
            title: qsTr("You have %1 package(s) installed").arg(App.installedModel.totalCount)
            subtitle: root.kindLine()
            actions: [
                AccentButton {
                    subtle: true
                    text: qsTr("View installed")
                    onClicked: root.navigate(2)
                }
            ]
        }

        SummaryCard {
            visible: App.installedModel.pinnedCount > 0
            icon: "📌"
            title: qsTr("%1 pinned package(s)").arg(App.installedModel.pinnedCount)
            subtitle: qsTr("Pinned packages are excluded from bulk upgrades")
        }

        SummaryCard {
            icon: App.cliAvailable ? "⚡" : "⚠"
            title: App.cliAvailable
                   ? qsTr("%1 is ready").arg(App.managerName)
                   : qsTr("%1 CLI not found").arg(App.managerName)
            subtitle: App.cliAvailable
                      ? App.cliVersion + "  ·  " + App.cliPath
                      : qsTr("Install the CLI and re-detect it in Settings")
            actions: [
                AccentButton {
                    subtle: true
                    text: App.cliAvailable ? qsTr("Settings") : qsTr("Re-detect")
                    onClicked: App.cliAvailable ? root.navigate(6)
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
