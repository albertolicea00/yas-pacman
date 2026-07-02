import QtQuick
import Yas.Core

Column {
    spacing: Theme.spacing

    Text {
        text: qsTr("Settings")
        color: Theme.textPrimary
        font.family: Theme.headingFont
        font.pixelSize: 16
        font.weight: Font.DemiBold
    }

    Rectangle {
        width: parent.width
        height: cliColumn.height + 28
        radius: Theme.radius
        color: Theme.surface
        border.color: Theme.border

        Column {
            id: cliColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 6

            Text {
                text: qsTr("CLI backend")
                color: Theme.textPrimary
                font.family: Theme.uiFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
            Text {
                text: App.cliAvailable
                      ? qsTr("%1 detected at %2").arg(App.managerName).arg(App.cliPath)
                      : qsTr("%1 CLI not found — install it and hit Re-detect")
                            .arg(App.managerName)
                color: App.cliAvailable ? Theme.success : Theme.danger
                font.family: Theme.monoFont
                font.pixelSize: 12
                wrapMode: Text.WrapAnywhere
                width: parent.width
            }
            Text {
                visible: App.cliAvailable
                text: App.cliVersion
                color: Theme.textSecondary
                font.family: Theme.monoFont
                font.pixelSize: 12
            }
            AccentButton {
                subtle: true
                text: qsTr("Re-detect")
                onClicked: { App.redetectCli(); if (App.cliAvailable) App.initialize() }
            }
        }
    }
}
