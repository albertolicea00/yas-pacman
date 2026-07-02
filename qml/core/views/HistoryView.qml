import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// "Command Reminder Companion": persistent history of every command run.
// Not in the rail — reached from Settings.
Column {
    id: historyRoot
    signal back()
    spacing: Theme.spacing

    Row {
        width: parent.width
        spacing: Theme.spacing

        IconButton {
            icon: "‹"
            label: qsTr("Back to settings")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: historyRoot.back()
        }
        IconButton {
            icon: "⌫"
            label: qsTr("Clear history")
            tint: Theme.danger
            anchors.verticalCenter: parent.verticalCenter
            onClicked: App.commandLog.clear()
        }
    }

    ListView {
        width: parent.width
        height: parent.height - y
        clip: true
        spacing: 4
        model: App.commandLog
        ScrollBar.vertical: ScrollBar {}

        delegate: Rectangle {
            width: ListView.view.width
            height: 52
            radius: Theme.radius
            color: Theme.surface
            border.color: Theme.border

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: copyBtn.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    text: model.commandLine
                    color: model.running ? Theme.accent
                                         : model.succeeded ? Theme.textPrimary : Theme.danger
                    font.family: Theme.monoFont
                    font.pixelSize: Theme.fs(12)
                    elide: Text.ElideMiddle
                }
                Text {
                    text: Qt.formatDateTime(model.timestamp, "yyyy-MM-dd hh:mm:ss")
                          + (model.running ? qsTr("  · running")
                                           : qsTr("  · exit %1 · %2 ms")
                                                 .arg(model.exitCode).arg(model.durationMs))
                    color: Theme.textSecondary
                    font.family: Theme.uiFont
                    font.pixelSize: Theme.fs(10)
                }
            }

            IconButton {
                id: copyBtn
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                icon: "⧉"
                tooltip: qsTr("Copy command")
                onClicked: {
                    copyHelper.text = model.commandLine
                    copyHelper.selectAll()
                    copyHelper.copy()
                }
            }
        }
    }

    TextEdit { id: copyHelper; visible: false }
}
