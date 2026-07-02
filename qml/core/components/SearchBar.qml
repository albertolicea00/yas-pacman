import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

Rectangle {
    id: root
    property alias text: field.text
    property alias placeholder: field.placeholderText
    signal accepted(string query)

    implicitHeight: 40
    radius: Theme.radius
    color: Theme.surface
    border.color: field.activeFocus ? Theme.accent : Theme.border

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "⌕"
            color: Theme.textSecondary
            font.pixelSize: 18
        }

        TextField {
            id: field
            width: parent.width - 60
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textPrimary
            placeholderTextColor: Theme.textSecondary
            font.family: Theme.uiFont
            font.pixelSize: 14
            background: null
            onAccepted: root.accepted(text)
        }
    }
}
