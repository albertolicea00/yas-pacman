import QtQuick
import Yas.Core

Column {
    spacing: Theme.spacing

    Text {
        width: parent.width
        text: App.outdatedModel.count === 0
              ? qsTr("Everything is up to date")
              : qsTr("%1 update(s) available").arg(App.outdatedModel.count)
        color: Theme.textPrimary
        font.family: Theme.headingFont
        font.pixelSize: 16
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    Row {
        spacing: Theme.spacing
        AccentButton {
            enabled: App.outdatedModel.count > 0
            text: qsTr("Upgrade all")
            onClicked: App.upgradeAll()
        }
        AccentButton {
            subtle: true
            text: qsTr("Check again")
            onClicked: App.refreshOutdated()
        }
    }

    PackageBrowser {
        width: parent.width
        height: parent.height - y
        model: App.outdatedModel
        emptyText: qsTr("No pending updates")
    }
}
