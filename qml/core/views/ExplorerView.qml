import QtQuick
import Yas.Core

// Search the remote catalog of the package manager.
PackageBrowser {
    title: qsTr("Explore")
    model: App.searchModel
    placeholder: qsTr("Search packages (press Enter)")
    emptyText: qsTr("Search to explore available packages")
    onSearch: query => App.search(query)
}
