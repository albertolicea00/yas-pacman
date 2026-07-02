import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Yas.Manager

Rectangle {
    id: detailsPanel

    color: Theme.panelBg
    border.color: Theme.borderColor
    border.width: 1

    property string currentRepo: "yas-core"

    function showDetails(repoName) {
        currentRepo = repoName
    }

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
                text: qsTr("Details")
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Content
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentCol.implicitHeight
            clip: true

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 0

                // Name section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: Theme.bgSecondary
                    border.color: Theme.borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        Text {
                            text: qsTr("NAME")
                            color: Theme.textSecondary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            text.toUpperCase: true
                        }

                        Text {
                            text: detailsPanel.currentRepo
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontSize
                            font.weight: Font.Medium
                        }
                    }
                }

                // Status
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: Theme.panelBg
                    border.color: Theme.borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        Text {
                            text: qsTr("STATUS")
                            color: Theme.textSecondary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        Rectangle {
                            color: Theme.statusCleanBg
                            radius: 3
                            Layout.preferredHeight: 22
                            Layout.preferredWidth: 80

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Clean")
                                color: Theme.statusClean
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                // Info
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Theme.bgSecondary
                    border.color: Theme.borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: qsTr("INFORMATION")
                            color: Theme.textSecondary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        RowLayout {
                            Text { text: qsTr("Branch:"); color: Theme.textSecondary; font.pixelSize: Theme.fontSizeSmall }
                            Text { text: "main"; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                        }

                        RowLayout {
                            Text { text: qsTr("Commits:"); color: Theme.textSecondary; font.pixelSize: Theme.fontSizeSmall }
                            Text { text: "142"; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                        }

                        RowLayout {
                            Text { text: qsTr("Updated:"); color: Theme.textSecondary; font.pixelSize: Theme.fontSizeSmall }
                            Text { text: "hace 2 horas"; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                        }
                    }
                }

                // Description
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: Theme.panelBg
                    border.color: Theme.borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: qsTr("DESCRIPTION")
                            color: Theme.textSecondary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "Core repository with shared business logic"
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }

                // Actions
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: Theme.bgSecondary
                    border.color: Theme.borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: qsTr("ACTIONS")
                            color: Theme.textSecondary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        Button {
                            text: qsTr("Push")
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: Theme.accentColor
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: qsTr("Pull")
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: Theme.bgTertiary
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: Theme.textPrimary
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
