import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Teams-style list + detail: flush full-height list panel (section title,
// search, optional action row, rows) separated from the detail pane by a
// 1px divider — no floating cards.
Item {
    id: root
    property alias model: list.model
    property alias emptyText: empty.text
    property string title: ""
    property string placeholder: ""      // empty -> no search field
    property bool liveFilter: false      // true -> text drives model.filter
    signal search(string query)
    property alias headerExtra: extraRow.data
    property int selectedRow: -1

    function clearSelection() {
        selectedRow = -1
        detail.pkg = ({})
    }

    Rectangle {
        id: listPanel
        width: Theme.listPanelWidth
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Theme.surface

        Column {
            anchors.fill: parent
            anchors.margins: 12
            anchors.bottomMargin: 0
            spacing: 10

            Text {
                visible: root.title.length > 0
                text: root.title
                color: Theme.textPrimary
                font.family: Theme.headingFont
                font.pixelSize: 18
                font.weight: Font.Bold
            }

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
                spacing: 1
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

    Rectangle { // divider between list and detail
        anchors.left: listPanel.right
        width: 1
        height: parent.height
        color: Theme.border
    }

    DetailPane {
        id: detail
        anchors.left: listPanel.right
        anchors.leftMargin: 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
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
