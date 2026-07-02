import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

ItemDelegate {
    id: control
    required property int index
    required property string packageId
    required property string name
    required property string version
    required property string installedVersion
    required property string description
    required property string kind
    required property bool pinned
    required property bool installed
    required property bool outdated

    property bool selected: false

    width: ListView.view ? ListView.view.width : implicitWidth
    height: 64

    background: Rectangle {
        radius: Theme.radius
        color: control.selected ? Theme.accentSubtle
                                : control.hovered ? Theme.surfaceAlt : "transparent"
        border.color: control.selected ? Theme.accent : "transparent"
    }

    contentItem: Row {
        spacing: 12

        Column {
            width: parent.width - statusRow.width - 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Row {
                spacing: 8
                Text {
                    text: control.name
                    color: Theme.textPrimary
                    font.family: Theme.uiFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                TagBadge {
                    visible: control.kind.length > 0
                    text: control.kind
                    tint: Theme.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                width: parent.width
                text: control.description.length > 0 ? control.description : control.packageId
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        Row {
            id: statusRow
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            TagBadge { visible: control.pinned; text: qsTr("PINNED"); tint: Theme.accent }
            TagBadge { visible: control.outdated; text: qsTr("UPDATE"); tint: Theme.danger }
            TagBadge {
                visible: control.installed && !control.outdated
                text: qsTr("INSTALLED")
                tint: Theme.success
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: control.installedVersion.length > 0
                      ? control.installedVersion
                      : control.version
                color: Theme.textSecondary
                font.family: Theme.monoFont
                font.pixelSize: 12
            }
        }
    }
}
