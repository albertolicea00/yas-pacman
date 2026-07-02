import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Yas.Manager

ApplicationWindow {
    id: root

    width: 1400
    height: 800
    minimumWidth: 1000
    minimumHeight: 600

    color: Theme.bgPrimary

    menuBar: MenuBar {
        id: menuBar

        Menu {
            title: qsTr("&File")
            Action { text: qsTr("&Exit"); onTriggered: Qt.quit() }
        }

        Menu {
            title: qsTr("&View")
            Action {
                text: qsTr("&Dark Mode")
                checkable: true
                checked: Theme.isDark
                onTriggered: Theme.toggleDarkMode()
            }
        }

        Menu {
            title: qsTr("&Help")
            Action { text: qsTr("&About") }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // Header
        Rectangle {
            color: Theme.bgSecondary
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            border.color: Theme.borderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    text: qsTr("YAS Repos Manager")
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Main content (3 panels)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Sidebar
            SideMenu {
                id: sideMenu
                Layout.preferredWidth: 280
                Layout.fillHeight: true
            }

            // List Panel
            ListPanel {
                id: listPanel
                Layout.fillWidth: true
                Layout.fillHeight: true
                onRepoSelected: detailsPanel.showDetails(name)
            }

            // Details Panel
            DetailsPanel {
                id: detailsPanel
                Layout.preferredWidth: 380
                Layout.fillHeight: true
            }
        }
    }
}
