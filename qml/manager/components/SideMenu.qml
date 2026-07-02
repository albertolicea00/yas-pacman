import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Yas.Manager

Rectangle {
    id: sideMenu

    color: Theme.panelBg
    border.color: Theme.borderColor
    border.width: 1

    signal menuSelected(string menu)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // Header
        Rectangle {
            color: Theme.bgSecondary
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            border.color: Theme.borderColor
            border.width: 1

            Text {
                anchors.fill: parent
                anchors.margins: 16
                text: qsTr("Menu")
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Menu items
        ListView {
            id: menuList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: ListModel {
                ListElement { text: "📦 Repositories"; id: "repos" }
                ListElement { text: "📝 Changes"; id: "changes" }
                ListElement { text: "📅 History"; id: "history" }
                ListElement { text: "⚙️ Settings"; id: "settings" }
            }

            delegate: Rectangle {
                width: menuList.width
                height: 48
                color: mouseArea.containsMouse ? Theme.hoverBg : (index === 0 ? Theme.hoverBg : Theme.panelBg)
                border.color: index === 0 ? Theme.accentColor : "transparent"
                border.width: index === 0 ? 3 : 0
                border.leftMargin: 0

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    text: model.text
                    color: index === 0 ? Theme.textPrimary : Theme.textSecondary
                    font.pixelSize: Theme.fontSize
                    font.weight: index === 0 ? Font.Medium : Font.Normal
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        menuList.currentIndex = index
                        sideMenu.menuSelected(model.id)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
