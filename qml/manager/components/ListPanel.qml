import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Yas.Manager

Rectangle {
    id: listPanel

    color: Theme.panelBg
    border.color: Theme.borderColor
    border.width: 1

    signal repoSelected(string name)

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
                text: qsTr("Repositories")
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
            }
        }

        // List
        ListView {
            id: repoList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: ListModel {
                ListElement { name: "yas-core"; desc: "Núcleo principal"; status: "clean" }
                ListElement { name: "yas-web"; desc: "Aplicación web"; status: "dirty" }
                ListElement { name: "yas-apt"; desc: "Gestor APT"; status: "clean" }
                ListElement { name: "yas-brew"; desc: "Gestor Brew"; status: "clean" }
                ListElement { name: "yas-nix"; desc: "Gestor Nix"; status: "dirty" }
                ListElement { name: "yas-snap"; desc: "Gestor Snap"; status: "clean" }
                ListElement { name: "yas-flatpak"; desc: "Gestor Flatpak"; status: "clean" }
                ListElement { name: "yas-pacman"; desc: "Gestor Pacman"; status: "clean" }
                ListElement { name: "yas-scoop"; desc: "Gestor Scoop"; status: "clean" }
                ListElement { name: "yas-choco"; desc: "Gestor Chocolatey"; status: "dirty" }
                ListElement { name: "yas-winget"; desc: "Gestor Winget"; status: "clean" }
                ListElement { name: "yas-yay"; desc: "Gestor Yay"; status: "clean" }
            }

            delegate: Rectangle {
                width: repoList.width
                height: 56
                color: mouseArea.containsMouse ? Theme.hoverBg : (index === 0 ? Theme.hoverBg : Theme.panelBg)
                border.color: index === 0 ? Theme.accentColor : "transparent"
                border.width: index === 0 ? 3 : 0
                border.leftMargin: 0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 2

                    Text {
                        text: model.name
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Medium
                    }

                    Text {
                        text: model.desc
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        repoList.currentIndex = index
                        listPanel.repoSelected(model.name)
                    }
                }
            }
        }
    }
}
