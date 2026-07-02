import QtQuick
import Yas.Core

PackageBrowser {
    id: installedView
    model: App.installedModel
    placeholder: qsTr("Filter installed packages")
    liveFilter: true
    emptyText: qsTr("No installed packages found")
    showRefresh: true
    onRefresh: App.refreshInstalled()

    // Default package type (Settings > Packages); re-applied when changed.
    Component.onCompleted: model.kindFilter = YasManager.defaultKind
    Connections {
        target: YasManager
        function onDefaultKindChanged() {
            installedView.model.kindFilter = YasManager.defaultKind
        }
    }
}
