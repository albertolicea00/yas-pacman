import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Settings row: label + description on the left, a themed switch on the right.
Item {
    id: root
    property string label: ""
    property string description: ""
    property alias checked: control.checked
    signal toggled(bool checked)

    width: parent ? parent.width : implicitWidth
    implicitHeight: Math.max(40, textColumn.implicitHeight + 12)

    Column {
        id: textColumn
        anchors.left: parent.left
        anchors.right: control.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            width: parent.width
            text: root.label
            color: Theme.textPrimary
            font.family: Theme.uiFont
            font.pixelSize: 13
        }
        Text {
            width: parent.width
            visible: root.description.length > 0
            text: root.description
            color: Theme.textSecondary
            font.family: Theme.uiFont
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }
    }

    Switch {
        id: control
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        onToggled: root.toggled(checked)

        indicator: Rectangle {
            implicitWidth: 38
            implicitHeight: 22
            radius: 11
            color: control.checked ? Theme.accent : Theme.surfaceAlt
            border.color: control.checked ? Theme.accent : Theme.border

            Rectangle {
                x: control.checked ? parent.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                width: 16; height: 16; radius: 8
                color: "#FFFFFF"
                Behavior on x { NumberAnimation { duration: 100 } }
            }
        }
    }
}
