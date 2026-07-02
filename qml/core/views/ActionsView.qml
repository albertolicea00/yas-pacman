import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Full CLI coverage: every extra function of the wrapped manager (doctor,
// cache cleanup, dependency trees...) exposed as one-click actions.
Column {
    id: root
    spacing: Theme.spacing

    property string packageForActions: ""

    Text {
        text: qsTr("Actions — full %1 toolbox").arg(App.managerName)
        color: Theme.textPrimary
        font.family: Theme.headingFont
        font.pixelSize: Theme.fs(16)
        font.weight: Font.DemiBold
    }

    SearchBar {
        id: pkgField
        width: parent.width
        placeholder: qsTr("Package name for package-scoped actions (optional)")
        onTextChanged: root.packageForActions = text.trim()
    }

    ListView {
        width: parent.width
        height: parent.height - y
        clip: true
        spacing: 6
        model: App.actions
        ScrollBar.vertical: ScrollBar {}

        delegate: Rectangle {
            width: ListView.view.width
            height: 66
            radius: Theme.radius
            color: Theme.surface
            border.color: Theme.border

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: runBtn.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Row {
                    spacing: 8
                    Text {
                        text: modelData.title
                        color: Theme.textPrimary
                        font.family: Theme.uiFont
                        font.pixelSize: Theme.fs(14)
                        font.weight: Font.DemiBold
                    }
                    TagBadge {
                        visible: modelData.needsPackage
                        text: qsTr("PER-PACKAGE")
                        tint: Theme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TagBadge {
                        visible: modelData.destructive
                        text: qsTr("CAUTION")
                        tint: Theme.danger
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    width: parent.width
                    text: modelData.description + "  ·  " + modelData.commandPreview
                          + (modelData.needsPackage ? " <pkg>" : "")
                    color: Theme.textSecondary
                    font.family: Theme.monoFont
                    font.pixelSize: Theme.fs(11)
                    elide: Text.ElideRight
                }
            }

            AccentButton {
                id: runBtn
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                subtle: modelData.destructive
                danger: modelData.destructive
                enabled: !modelData.needsPackage || root.packageForActions.length > 0
                text: qsTr("Run")
                onClicked: {
                    if (modelData.destructive)
                        confirmDialog.openFor(modelData.actionId, modelData.title)
                    else
                        App.runAction(modelData.actionId, root.packageForActions)
                }
            }
        }
    }

    YasDialog {
        id: confirmDialog
        property string actionId: ""
        title: qsTr("Confirm")
        destructive: true
        acceptText: qsTr("Run")

        function openFor(id, name) {
            actionId = id
            confirmText.text = qsTr("Run \"%1\"? This may remove data.").arg(name)
            open()
        }

        Text {
            id: confirmText
            color: Theme.textPrimary
            font.family: Theme.uiFont
            font.pixelSize: Theme.fs(13)
        }
        onAccepted: App.runAction(actionId, root.packageForActions)
    }
}
