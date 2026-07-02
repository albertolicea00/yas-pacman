import QtQuick
import Yas.Core

Rectangle {
    property alias text: label.text
    property color tint: Theme.accent

    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 6
    radius: height / 2
    color: Qt.rgba(tint.r, tint.g, tint.b, 0.12)
    border.color: Qt.rgba(tint.r, tint.g, tint.b, 0.5)

    Text {
        id: label
        anchors.centerIn: parent
        color: parent.tint
        font.family: Theme.uiFont
        font.pixelSize: 11
        font.weight: Font.DemiBold
        font.letterSpacing: 1
    }
}
