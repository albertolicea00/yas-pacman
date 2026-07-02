import QtQuick
import Yas.Core

PackageBrowser {
    title: qsTr("Updates")
    model: App.outdatedModel
    emptyText: qsTr("Everything is up to date")
    showRefresh: true
    onRefresh: App.refreshOutdated()
    headerExtra: [
        AccentButton {
            visible: App.outdatedModel.count > 0
            text: qsTr("Upgrade all (%1)").arg(App.outdatedModel.count)
            onClicked: App.upgradeAll()
        }
    ]
}
