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
    required property string homepage
    required property string kind
    required property bool pinned
    required property bool installed
    required property bool outdated

    property bool selected: false

    width: ListView.view ? ListView.view.width : implicitWidth
    height: Theme.fs(58)

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

        Item { // app icon, plain (no circle); puzzle piece when unavailable
            width: Theme.fs(30); height: Theme.fs(30)
            anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                visible: rowFavicon.status !== Image.Ready
                text: "🧩"
                font.pixelSize: Theme.fs(20)
            }
            Image {
                id: rowFavicon
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: status === Image.Ready
                source: {
                    if (control.homepage.length === 0)
                        return ""
                    const host = control.homepage.split("/")[2] || ""
                    return host.length > 0
                           ? "https://www.google.com/s2/favicons?domain=" + host + "&sz=64"
                           : ""
                }
            }
        }

        Column {
            width: parent.width - Theme.fs(30) - statusColumn.width - 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                width: parent.width
                text: control.name
                color: Theme.textPrimary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(13)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                visible: YasManager.showDescriptions
                text: control.description.length > 0 ? control.description : control.packageId
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(11)
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
                font.pixelSize: Theme.fs(10)
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
