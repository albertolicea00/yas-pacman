import QtQuick
import Yas.Core

PackageBrowser {
    model: App.installedModel
    placeholder: qsTr("Filter installed packages")
    liveFilter: true
    emptyText: qsTr("No installed packages found")
    showRefresh: true
    onRefresh: App.refreshInstalled()
}
