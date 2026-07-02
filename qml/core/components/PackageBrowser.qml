import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Reusable list + detail split used by Explorer/Installed/Updates views.
Item {
    id: root
    property alias model: list.model
    property alias emptyText: empty.text
    property int selectedRow: -1

    function clearSelection() {
        selectedRow = -1
        detail.pkg = ({})
    }

    Row {
        anchors.fill: parent
        spacing: Theme.spacing

        Rectangle {
            width: parent.width * 0.58
            height: parent.height
            color: "transparent"

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 4
                delegate: PackageDelegate {
                    selected: index === root.selectedRow
                    onClicked: {
                        root.selectedRow = index
                        detail.pkg = list.model.get(index)
                    }
                }
                ScrollBar.vertical: ScrollBar {}
            }

            Text {
                id: empty
                anchors.centerIn: parent
                visible: list.count === 0
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: 14
            }
        }

        DetailPane {
            id: detail
            width: parent.width * 0.42 - Theme.spacing
            height: parent.height
        }
    }

    Connections {
        target: root.model
        function onCountChanged() {
            if (root.selectedRow >= root.model.count)
                root.clearSelection()
            else if (root.selectedRow >= 0)
                detail.pkg = root.model.get(root.selectedRow)
        }
    }
}
