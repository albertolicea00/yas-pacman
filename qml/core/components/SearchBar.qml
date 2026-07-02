import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

Rectangle {
    id: root
    property alias text: field.text
    property alias placeholder: field.placeholderText
    property alias bg: root.color
    signal accepted(string query)

    implicitHeight: 36
    radius: Theme.radius
    color: Theme.surface
    border.color: field.activeFocus ? Theme.accent : Theme.border

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "⌕"
            color: Theme.textSecondary
            font.pixelSize: 16
        }

        TextField {
            id: field
            width: parent.width - 40
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textPrimary
            placeholderTextColor: Theme.textSecondary
            font.family: Theme.uiFont
            font.pixelSize: 13
            background: null
            onAccepted: root.accepted(text)
        }
    }
}
