import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

Button {
    id: control
    property bool danger: false
    property bool subtle: false

    readonly property color mainColor: danger ? Theme.danger : Theme.accent

    contentItem: Text {
        text: control.text
        color: control.subtle ? control.mainColor
                              : (control.enabled ? "#141420" : Theme.textSecondary)
        font.family: Theme.uiFont
        font.pixelSize: Theme.fs(13)
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitHeight: 32
        implicitWidth: 84
        radius: Theme.radius
        color: control.subtle
               ? (control.hovered ? Qt.rgba(control.mainColor.r, control.mainColor.g, control.mainColor.b, 0.15)
                                  : Qt.rgba(control.mainColor.r, control.mainColor.g, control.mainColor.b, 0.08))
               : (control.enabled
                  ? (control.pressed ? Qt.darker(control.mainColor, 1.2)
                                     : control.hovered ? Qt.lighter(control.mainColor, 1.1)
                                                       : control.mainColor)
                  : Theme.surfaceAlt)
        border.color: control.subtle ? Qt.rgba(control.mainColor.r, control.mainColor.g, control.mainColor.b, 0.4)
                                     : "transparent"
    }
}
