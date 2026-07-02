import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Teams-style list + detail split: a fixed-width list panel (search on top,
// optional extra header row, package list) next to the detail pane.
Item {
    id: root
    property alias model: list.model
    property alias emptyText: empty.text
    property string placeholder: ""      // empty -> no search field
    property bool liveFilter: false      // true -> text drives model.filter
    signal search(string query)
    property alias headerExtra: extraRow.data
    property int selectedRow: -1

    function clearSelection() {
        selectedRow = -1
        detail.pkg = ({})
    }

    Row {
        anchors.fill: parent
        spacing: Theme.spacing

        Rectangle {
            id: listPanel
            width: Theme.listPanelWidth
            height: parent.height
            radius: Theme.radius
            color: Theme.surface
            border.color: Theme.border

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                SearchBar {
                    id: searchField
                    visible: root.placeholder.length > 0
                    width: parent.width
                    bg: Theme.base
                    placeholder: root.placeholder
                    onAccepted: query => root.search(query)
                    onTextChanged: if (root.liveFilter && root.model)
                                       root.model.filter = text
                }

                Row {
                    id: extraRow
                    width: parent.width
                    spacing: 8
                    visible: children.length > 0
                }

                ListView {
                    id: list
                    width: parent.width
                    height: parent.height - y
                    clip: true
                    spacing: 2
                    delegate: PackageDelegate {
                        selected: index === root.selectedRow
                        onClicked: {
                            root.selectedRow = index
                            detail.pkg = list.model.get(index)
                        }
                    }
                    ScrollBar.vertical: ScrollBar {}
                }
            }

            Text {
                id: empty
                anchors.centerIn: parent
                width: parent.width - 40
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: list.count === 0
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: 13
            }
        }

        DetailPane {
            id: detail
            width: parent.width - listPanel.width - Theme.spacing
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
