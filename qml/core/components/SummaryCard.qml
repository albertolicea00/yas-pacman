import QtQuick
import Yas.Core

// Home-view status card: rounded icon, title + subtitle, action buttons.
Rectangle {
    id: root
    property alias icon: iconGlyph.text
    property string title: ""
    property string subtitle: ""
    property alias actions: actionsRow.data

    width: parent ? parent.width : implicitWidth
    implicitHeight: Math.max(72, textColumn.implicitHeight + 28)
    radius: Theme.radius
    color: Theme.surface

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: actionsRow.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        Rectangle {
            width: 42; height: 42
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.accentSubtle
            Text {
                id: iconGlyph
                anchors.centerIn: parent
                font.pixelSize: Theme.fs(19)
                color: Theme.accent
            }
        }

        Column {
            id: textColumn
            width: parent.width - 42 - 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                width: parent.width
                text: root.title
                color: Theme.textPrimary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(14)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }
            Text {
                width: parent.width
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(12)
                wrapMode: Text.WordWrap
            }
        }
    }

    Row {
        id: actionsRow
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }
}
