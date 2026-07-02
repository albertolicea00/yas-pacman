import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Themed modal dialog matching the suite style — replaces the raw Basic
// Dialog chrome (black header, gray buttons).
Dialog {
    id: control
    property string acceptText: qsTr("OK")
    property string cancelText: qsTr("Cancel")
    property bool showCancel: true
    property bool destructive: false

    anchors.centerIn: Overlay.overlay
    modal: true
    padding: 16

    background: Rectangle {
        color: Theme.surface
        radius: Theme.radius
        border.color: Theme.border
    }

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, Theme.dark ? 0.5 : 0.3)
    }

    header: Item {
        implicitHeight: control.title.length > 0 ? Theme.fs(44) : 0
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: control.title
            color: Theme.textPrimary
            font.family: Theme.headingFont
            font.pixelSize: Theme.fs(15)
            font.weight: Font.DemiBold
        }
    }

    footer: Item {
        implicitHeight: Theme.fs(52)
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            AccentButton {
                visible: control.showCancel
                subtle: true
                text: control.cancelText
                onClicked: control.reject()
            }
            AccentButton {
                danger: control.destructive
                text: control.acceptText
                onClicked: control.accept()
            }
        }
    }
}
