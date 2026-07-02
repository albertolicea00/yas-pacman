import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Teams-style list + detail. The list takes the full width until a package
// is selected; then the detail pane opens on the right (~5/12) and can be
// closed again from its ✕ button. Kind filter chips sit left on the same
// line as the section action buttons (headerExtra, right).
Item {
    id: root
    property alias model: list.model
    property alias emptyText: empty.text
    property string title: ""
    property string placeholder: ""      // empty -> no search field
    property bool liveFilter: false      // true -> text drives model.filter
    property bool showRefresh: false
    signal refresh()
    signal search(string query)
    property alias headerExtra: extraRow.data
    property Component emptyContent: null
    property int selectedRow: -1
    readonly property bool detailOpen: selectedRow >= 0

    function clearSelection() {
        selectedRow = -1
        detail.pkg = ({})
    }

    Rectangle {
        id: listPanel
        width: root.detailOpen ? Math.round(root.width * 7 / 12) : root.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Theme.surface
        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            anchors.bottomMargin: 0
            spacing: 10

            Row {
                width: parent.width
                spacing: 6
                visible: root.title.length > 0 || (root.showRefresh && root.placeholder.length === 0)

                Text {
                    visible: root.title.length > 0
                    width: parent.width - (refreshTitleBtn.visible ? refreshTitleBtn.width + 6 : 0)
                    text: root.title
                    color: Theme.textPrimary
                    font.family: Theme.headingFont
                    font.pixelSize: Theme.fs(18)
                    font.weight: Font.Bold
                }
                IconButton {
                    id: refreshTitleBtn
                    visible: root.showRefresh && root.placeholder.length === 0
                    icon: "↻"
                    tooltip: qsTr("Refresh")
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.refresh()
                }
            }

            Row {
                width: parent.width
                spacing: 6
                visible: root.placeholder.length > 0

                SearchBar {
                    id: searchField
                    visible: root.placeholder.length > 0
                    width: parent.width - (refreshBtn.visible ? refreshBtn.width + 6 : 0)
                    bg: Theme.base
                    placeholder: root.placeholder
                    onAccepted: query => root.search(query)
                    onTextChanged: if (root.liveFilter && root.model)
                                       root.model.filter = text
                }
                IconButton {
                    id: refreshBtn
                    visible: root.showRefresh && searchField.visible
                    icon: "↻"
                    tooltip: qsTr("Refresh")
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.refresh()
                }
            }

            // Kind filter chips (left) + section action buttons (right).
            Item {
                width: parent.width
                height: Math.max(chipsFlow.implicitHeight, extraRow.implicitHeight)
                visible: chipsFlow.visible || extraRow.children.length > 0

                Flow {
                    id: chipsFlow
                    anchors.left: parent.left
                    anchors.right: extraRow.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    visible: root.model && root.model.kindSummary !== undefined
                             && root.model.kindSummary.length > 1

                    Repeater {
                        model: (root.model && root.model.kindSummary !== undefined
                                && root.model.kindSummary.length > 1)
                               ? [{kind: "", count: root.model.totalCount}].concat(
                                     root.model.kindSummary)
                               : []
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool active:
                                root.model.kindFilter === modelData.kind
                            width: chipLabel.implicitWidth + 18
                            height: 24
                            radius: 12
                            color: active ? Theme.accentSubtle : Theme.base
                            border.color: active ? Theme.accent : Theme.border

                            Text {
                                id: chipLabel
                                anchors.centerIn: parent
                                text: (modelData.kind.length > 0 ? modelData.kind
                                                                 : qsTr("all"))
                                      + " " + modelData.count
                                color: parent.active ? Theme.accent : Theme.textSecondary
                                font.family: Theme.uiFont
                                font.pixelSize: Theme.fs(11)
                            }
                            TapHandler {
                                onTapped: root.model.kindFilter = modelData.kind
                            }
                        }
                    }
                }

                Row {
                    id: extraRow
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                }
            }

            ListView {
                id: list
                width: parent.width
                height: parent.height - y
                visible: list.count > 0
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

            Loader {
                width: parent.width
                height: parent.height - y
                active: list.count === 0 && root.emptyContent !== null
                sourceComponent: root.emptyContent
            }
        }

        Text {
            id: empty
            anchors.centerIn: parent
            width: parent.width - 40
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: list.count === 0 && root.emptyContent === null
            color: Theme.textSecondary
            font.family: Theme.uiFont
            font.pixelSize: Theme.fs(13)
        }
    }

    Rectangle { // divider between list and detail
        visible: root.detailOpen
        anchors.left: listPanel.right
        width: 1
        height: parent.height
        color: Theme.border
    }

    DetailPane {
        id: detail
        visible: root.detailOpen
        anchors.left: listPanel.right
        anchors.leftMargin: 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        onCloseRequested: root.clearSelection()
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
