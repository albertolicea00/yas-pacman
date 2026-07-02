import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Minimal integrated button: a glyph with an optional text label — no chrome
// beyond a subtle hover background. Used for Clear/Refresh/package ops.
Item {
    id: root
    property alias icon: glyph.text
    property string label: ""
    property color tint: Theme.textSecondary
    property string tooltip: ""
    signal clicked()

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: Theme.fs(28)

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: hover.hovered ? Theme.surfaceAlt : "transparent"
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            id: glyph
            anchors.verticalCenter: parent.verticalCenter
            color: root.tint
            font.pixelSize: Theme.fs(14)
        }
        Text {
            visible: root.label.length > 0
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.tint
            font.family: Theme.uiFont
            font.pixelSize: Theme.fs(12)
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.clicked() }

    ToolTip.visible: hover.hovered && root.tooltip.length > 0
    ToolTip.text: root.tooltip
    ToolTip.delay: 450
}
