import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Right-hand pane showing the selected package + every operation on it.
Rectangle {
    id: root
    property var pkg: ({})  // QVariantMap from PackageListModel.get / infoReady
    readonly property bool hasPackage: pkg && pkg.packageId !== undefined

    color: Theme.surface
    radius: Theme.radius
    border.color: Theme.border

    Text {
        anchors.centerIn: parent
        visible: !root.hasPackage
        text: qsTr("Select a package")
        color: Theme.textSecondary
        font.family: Theme.uiFont
        font.pixelSize: 14
    }

    Column {
        visible: root.hasPackage
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        Text {
            width: parent.width
            text: root.hasPackage ? root.pkg.name : ""
            color: Theme.textPrimary
            font.family: Theme.headingFont
            font.pixelSize: 20
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        Row {
            spacing: 6
            TagBadge { visible: root.hasPackage && root.pkg.kind.length > 0; text: root.hasPackage ? root.pkg.kind : "" }
            TagBadge { visible: root.hasPackage && root.pkg.pinned; text: qsTr("PINNED") }
            TagBadge { visible: root.hasPackage && root.pkg.outdated; text: qsTr("UPDATE"); tint: Theme.danger }
        }

        Text {
            width: parent.width
            visible: root.hasPackage && root.pkg.description.length > 0
            text: root.hasPackage ? root.pkg.description : ""
            color: Theme.textSecondary
            font.family: Theme.uiFont
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }

        Column {
            spacing: 4
            Text {
                visible: root.hasPackage && root.pkg.version.length > 0
                text: qsTr("Latest: %1").arg(root.hasPackage ? root.pkg.version : "")
                color: Theme.textSecondary; font.family: Theme.monoFont; font.pixelSize: 12
            }
            Text {
                visible: root.hasPackage && root.pkg.installed
                text: qsTr("Installed: %1").arg(root.hasPackage ? root.pkg.installedVersion : "")
                color: Theme.textSecondary; font.family: Theme.monoFont; font.pixelSize: 12
            }
            Text {
                visible: root.hasPackage && root.pkg.source.length > 0
                text: qsTr("Source: %1").arg(root.hasPackage ? root.pkg.source : "")
                color: Theme.textSecondary; font.family: Theme.monoFont; font.pixelSize: 12
            }
        }

        Text {
            visible: root.hasPackage && root.pkg.homepage.length > 0
            text: root.hasPackage
                  ? "<a href=\"" + root.pkg.homepage + "\">" + root.pkg.homepage + "</a>" : ""
            color: Theme.accent
            linkColor: Theme.accent
            font.family: Theme.uiFont
            font.pixelSize: 12
            elide: Text.ElideRight
            width: parent.width
            onLinkActivated: link => Qt.openUrlExternally(link)
        }

        Item { width: 1; height: 8 }

        Flow {
            width: parent.width
            spacing: 8

            AccentButton {
                visible: root.hasPackage && !root.pkg.installed
                text: qsTr("Install")
                onClicked: App.install(root.pkg.packageId, root.pkg.kind)
            }
            AccentButton {
                visible: root.hasPackage && root.pkg.outdated
                text: qsTr("Upgrade")
                onClicked: App.upgrade(root.pkg.packageId, root.pkg.kind)
            }
            AccentButton {
                visible: root.hasPackage && root.pkg.installed
                         && App.canPin(root.pkg.packageId, root.pkg.kind)
                subtle: true
                text: root.hasPackage && root.pkg.pinned ? qsTr("Unpin") : qsTr("Pin")
                onClicked: root.pkg.pinned
                           ? App.unpin(root.pkg.packageId, root.pkg.kind)
                           : App.pin(root.pkg.packageId, root.pkg.kind)
            }
            AccentButton {
                visible: root.hasPackage && root.pkg.installed
                danger: true
                subtle: true
                text: qsTr("Uninstall")
                onClicked: App.uninstall(root.pkg.packageId, root.pkg.kind)
            }
            AccentButton {
                visible: root.hasPackage
                subtle: true
                text: qsTr("Details")
                onClicked: App.requestInfo(root.pkg.packageId, root.pkg.kind)
            }
        }
    }

    Connections {
        target: App
        function onInfoReady(packageMap) {
            if (root.hasPackage && packageMap.packageId === root.pkg.packageId)
                root.pkg = packageMap
        }
    }
}
