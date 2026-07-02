import QtQuick
import Yas.Core

PackageBrowser {
    model: App.installedModel
    placeholder: qsTr("Filter installed packages")
    liveFilter: true
    emptyText: qsTr("No installed packages found")
    headerExtra: [
        AccentButton {
            subtle: true
            text: qsTr("Refresh")
            onClicked: App.refreshInstalled()
        }
    ]
}
