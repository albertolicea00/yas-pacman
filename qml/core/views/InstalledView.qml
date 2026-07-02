import QtQuick
import Yas.Core

Column {
    spacing: Theme.spacing

    Row {
        width: parent.width
        spacing: Theme.spacing

        SearchBar {
            width: parent.width - refreshBtn.width - Theme.spacing
            placeholder: qsTr("Filter installed packages")
            onTextChanged: App.installedModel.filter = text
        }
        AccentButton {
            id: refreshBtn
            subtle: true
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Refresh")
            onClicked: App.refreshInstalled()
        }
    }

    PackageBrowser {
        width: parent.width
        height: parent.height - y
        model: App.installedModel
        emptyText: qsTr("No installed packages found")
    }
}
