import QtQuick
import Yas.Core

PackageBrowser {
    model: App.outdatedModel
    emptyText: qsTr("Everything is up to date")
    headerExtra: [
        AccentButton {
            enabled: App.outdatedModel.count > 0
            text: App.outdatedModel.count > 0
                  ? qsTr("Upgrade all (%1)").arg(App.outdatedModel.count)
                  : qsTr("Upgrade all")
            onClicked: App.upgradeAll()
        },
        AccentButton {
            subtle: true
            text: qsTr("Check again")
            onClicked: App.refreshOutdated()
        }
    ]
}
