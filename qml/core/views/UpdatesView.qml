import QtQuick
import Yas.Core

PackageBrowser {
    model: App.outdatedModel
    placeholder: qsTr("Filter pending updates")
    liveFilter: true
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
