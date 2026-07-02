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
    padding: 20
    // Size to the widest part (content vs buttons) so nothing overflows.
    width: Math.max(360, implicitWidth)

    background: Rectangle {
        color: Theme.surface
        radius: Theme.radius
        border.color: Theme.border
    }

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, Theme.dark ? 0.5 : 0.3)
    }

    header: Item {
        implicitHeight: control.title.length > 0 ? Theme.fs(46) : 0
        implicitWidth: headerText.implicitWidth + 40
        Text {
            id: headerText
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            text: control.title
            color: Theme.textPrimary
            font.family: Theme.headingFont
            font.pixelSize: Theme.fs(15)
            font.weight: Font.DemiBold
        }
    }

    footer: Item {
        implicitHeight: Theme.fs(58)
        implicitWidth: footerRow.implicitWidth + 40
        Row {
            id: footerRow
            anchors.right: parent.right
            anchors.rightMargin: 20
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
