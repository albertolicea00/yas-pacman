import QtQuick
import Yas.Core

// Search the remote catalog of the package manager.
Column {
    spacing: Theme.spacing

    SearchBar {
        width: parent.width
        placeholder: qsTr("Search packages (press Enter)")
        onAccepted: query => App.search(query)
    }

    PackageBrowser {
        width: parent.width
        height: parent.height - y
        model: App.searchModel
        emptyText: qsTr("Search to explore available packages")
    }
}
