import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Teams-style chat row: colored initial avatar, two text lines, status
// badges on the right.
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
    height: 58

    background: Rectangle {
        radius: Math.max(4, Theme.radius - 4)
        color: control.selected ? Theme.surfaceAlt
                                : control.hovered ? Qt.rgba(Theme.surfaceAlt.r,
                                                            Theme.surfaceAlt.g,
                                                            Theme.surfaceAlt.b, 0.55)
                                                  : "transparent"
    }

    contentItem: Row {
        spacing: 10

        Rectangle { // initial avatar
            width: 34; height: 34; radius: 17
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.accentSubtle
            Text {
                anchors.centerIn: parent
                text: control.name.length > 0 ? control.name.charAt(0).toUpperCase() : "?"
                color: Theme.accent
                font.family: Theme.uiFont
                font.pixelSize: 15
                font.weight: Font.Bold
            }
        }

        Column {
            width: parent.width - 34 - statusColumn.width - 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                width: parent.width
                text: control.name
                color: Theme.textPrimary
                font.family: Theme.uiFont
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                visible: YasManager.showDescriptions
                text: control.description.length > 0 ? control.description : control.packageId
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Column {
            id: statusColumn
            spacing: 3
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.right: parent.right
                text: control.installedVersion.length > 0 ? control.installedVersion
                                                          : control.version
                color: Theme.textSecondary
                font.family: Theme.monoFont
                font.pixelSize: 10
            }
            Row {
                anchors.right: parent.right
                spacing: 4
                TagBadge { visible: control.pinned; text: qsTr("PIN"); tint: Theme.accent }
                TagBadge { visible: control.outdated; text: "↑"; tint: Theme.danger }
                TagBadge {
                    visible: control.installed && !control.outdated
                    text: "✓"
                    tint: Theme.success
                }
            }
        }
    }
}
