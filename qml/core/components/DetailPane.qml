import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Right-hand pane for the selected package. Flat (Teams-style), operations
// as icon buttons in the top-right corner, details auto-loaded on selection
// (Settings-controlled). Emits closeRequested() so the browser can collapse.
Rectangle {
    id: root
    property var pkg: ({})  // QVariantMap from PackageListModel.get / infoReady
    readonly property bool hasPackage: pkg && pkg.packageId !== undefined
    property bool loading: false
    property string _fetchedId: ""
    property bool depsVisible: false
    property string depsOutput: ""
    signal closeRequested()

    color: "transparent"

    onPkgChanged: {
        if (!hasPackage) {
            _fetchedId = ""
            loading = false
            depsVisible = false
            depsOutput = ""
            return
        }
        if (pkg.packageId !== _fetchedId) {
            depsVisible = false
            depsOutput = ""
        }
        if (YasManager.autoLoadDetails && pkg.packageId !== _fetchedId) {
            _fetchedId = pkg.packageId
            loading = true
            App.requestInfo(pkg.packageId, pkg.kind)
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !root.hasPackage
        text: qsTr("Select a package")
        color: Theme.textSecondary
        font.family: Theme.uiFont
        font.pixelSize: Theme.fs(14)
    }

    Column {
        visible: root.hasPackage
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        // Header: favicon + name + operations pinned to the top-right corner.
        Row {
            width: parent.width
            spacing: 8

            Rectangle { // favicon with initial fallback
                width: Theme.fs(36); height: Theme.fs(36); radius: Theme.fs(18)
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.accentSubtle
                clip: true
                Text {
                    anchors.centerIn: parent
                    visible: favicon.status !== Image.Ready
                    text: root.hasPackage && root.pkg.name.length > 0
                          ? root.pkg.name.charAt(0).toUpperCase() : "?"
                    color: Theme.accent
                    font.family: Theme.uiFont
                    font.pixelSize: Theme.fs(16)
                    font.weight: Font.Bold
                }
                Image {
                    id: favicon
                    anchors.fill: parent
                    anchors.margins: 5
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready
                    source: {
                        if (!root.hasPackage || !root.pkg.homepage
                            || root.pkg.homepage.length === 0)
                            return ""
                        const host = root.pkg.homepage.split("/")[2] || ""
                        return host.length > 0
                               ? "https://www.google.com/s2/favicons?domain=" + host + "&sz=64"
                               : ""
                    }
                }
            }

            Text {
                width: parent.width - opsRow.implicitWidth - Theme.fs(36) - 16
                anchors.verticalCenter: parent.verticalCenter
                text: root.hasPackage ? root.pkg.name : ""
                color: Theme.textPrimary
                font.family: Theme.headingFont
                font.pixelSize: Theme.fs(20)
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Row {
                id: opsRow
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                IconButton {
                    visible: root.hasPackage && !root.pkg.installed
                    icon: "+"
                    label: qsTr("Install")
                    tint: Theme.accent
                    onClicked: App.install(root.pkg.packageId, root.pkg.kind)
                }
                IconButton {
                    visible: root.hasPackage && root.pkg.outdated
                    icon: "↑"
                    label: qsTr("Upgrade")
                    tint: Theme.accent
                    onClicked: root.confirmOrRun("upgrade")
                }
                IconButton {
                    visible: root.hasPackage && root.pkg.installed
                             && App.canPin(root.pkg.packageId, root.pkg.kind)
                    icon: root.hasPackage && root.pkg.pinned ? "⚑" : "⚐"
                    label: root.hasPackage && root.pkg.pinned ? qsTr("Unpin") : qsTr("Pin")
                    tint: root.hasPackage && root.pkg.pinned ? Theme.accent
                                                             : Theme.textSecondary
                    onClicked: root.pkg.pinned
                               ? App.unpin(root.pkg.packageId, root.pkg.kind)
                               : App.pin(root.pkg.packageId, root.pkg.kind)
                }
                IconButton {
                    visible: root.hasPackage && root.pkg.installed
                    icon: "−"
                    label: qsTr("Uninstall")
                    tint: Theme.danger
                    onClicked: root.confirmOrRun("uninstall")
                }
                IconButton {
                    icon: "✕"
                    tooltip: qsTr("Close details")
                    onClicked: root.closeRequested()
                }
            }
        }

        Row {
            spacing: 6
            TagBadge { visible: root.hasPackage && root.pkg.kind.length > 0; text: root.hasPackage ? root.pkg.kind : "" }
            TagBadge { visible: root.hasPackage && root.pkg.pinned; text: qsTr("PINNED") }
            TagBadge { visible: root.hasPackage && root.pkg.outdated; text: qsTr("UPDATE"); tint: Theme.danger }
        }

        Row {
            visible: root.loading
            spacing: 8
            BusyIndicator { width: 16; height: 16; running: root.loading }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Loading details…")
                color: Theme.textSecondary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(12)
            }
        }

        Text {
            width: parent.width
            visible: root.hasPackage && root.pkg.description.length > 0
            text: root.hasPackage ? root.pkg.description : ""
            color: Theme.textSecondary
            font.family: Theme.uiFont
            font.pixelSize: Theme.fs(13)
            wrapMode: Text.WordWrap
        }

        Column {
            spacing: 4
            Text {
                visible: root.hasPackage && root.pkg.version.length > 0
                text: qsTr("Latest: %1").arg(root.hasPackage ? root.pkg.version : "")
                color: Theme.textSecondary; font.family: Theme.monoFont; font.pixelSize: Theme.fs(12)
            }
            Text {
                visible: root.hasPackage && root.pkg.installed
                text: qsTr("Installed: %1").arg(root.hasPackage ? root.pkg.installedVersion : "")
                color: Theme.textSecondary; font.family: Theme.monoFont; font.pixelSize: Theme.fs(12)
            }
            Text {
                visible: root.hasPackage && root.pkg.source.length > 0
                text: qsTr("Source: %1").arg(root.hasPackage ? root.pkg.source : "")
                color: Theme.textSecondary; font.family: Theme.monoFont; font.pixelSize: Theme.fs(12)
            }
        }

        Text {
            visible: root.hasPackage && root.pkg.homepage.length > 0
            text: root.hasPackage
                  ? "<a href=\"" + root.pkg.homepage + "\">" + root.pkg.homepage + "</a>" : ""
            color: Theme.accent
            linkColor: Theme.accent
            font.family: Theme.uiFont
            font.pixelSize: Theme.fs(12)
            elide: Text.ElideRight
            width: parent.width
            onLinkActivated: link => Qt.openUrlExternally(link)
        }

        Row {
            spacing: 4
            IconButton {
                visible: root.hasPackage && root.pkg.installed
                         && (App.hasAction("deps") || App.hasAction("depends"))
                icon: root.depsVisible ? "▾" : "⇊"
                label: qsTr("Dependencies")
                tint: root.depsVisible ? Theme.accent : Theme.textSecondary
                tooltip: qsTr("Show what this package depends on")
                onClicked: {
                    root.depsVisible = !root.depsVisible
                    if (root.depsVisible && root.depsOutput.length === 0) {
                        const actionId = App.hasAction("deps") ? "deps" : "depends"
                        App.fetchActionOutput(actionId, root.pkg.packageId)
                    }
                }
            }
            IconButton {
                visible: root.hasPackage && !YasManager.autoLoadDetails
                icon: "ⓘ"
                label: qsTr("Load details")
                onClicked: {
                    root.loading = true
                    App.requestInfo(root.pkg.packageId, root.pkg.kind)
                }
            }
        }

        // Inline dependencies block (fills the remaining pane height).
        Rectangle {
            visible: root.depsVisible
            width: parent.width
            height: Math.max(80, parent.height - y)
            radius: Theme.radius
            color: Theme.base
            border.color: Theme.border

            Flickable {
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                contentHeight: depsText.implicitHeight
                ScrollBar.vertical: ScrollBar {}

                Text {
                    id: depsText
                    width: parent.width
                    text: root.depsOutput.length > 0 ? root.depsOutput : qsTr("Loading…")
                    color: Theme.textSecondary
                    font.family: Theme.monoFont
                    font.pixelSize: Theme.fs(12)
                    wrapMode: Text.WrapAnywhere
                    textFormat: Text.PlainText
                }
            }
        }
    }

    // Confirmation for destructive operations (Settings-controlled).
    function confirmOrRun(operation) {
        if (!YasManager.confirmDestructive) {
            runOperation(operation)
            return
        }
        confirmDialog.operation = operation
        confirmText.text = operation === "uninstall"
                           ? qsTr("Uninstall %1?").arg(pkg.packageId)
                           : qsTr("Upgrade %1 to %2?").arg(pkg.packageId).arg(pkg.version)
        confirmDialog.open()
    }

    function runOperation(operation) {
        if (operation === "uninstall")
            App.uninstall(pkg.packageId, pkg.kind)
        else
            App.upgrade(pkg.packageId, pkg.kind)
    }

    YasDialog {
        id: confirmDialog
        property string operation: ""
        title: qsTr("Confirm")
        destructive: operation === "uninstall"
        acceptText: operation === "uninstall" ? qsTr("Uninstall") : qsTr("Upgrade")
        Text {
            id: confirmText
            color: Theme.textPrimary
            font.family: Theme.uiFont
            font.pixelSize: Theme.fs(13)
        }
        onAccepted: root.runOperation(operation)
    }

    Connections {
        target: App
        function onInfoReady(packageMap) {
            if (root.hasPackage && packageMap.packageId === root.pkg.packageId) {
                root.pkg = packageMap
                root.loading = false
            }
        }
        function onActionOutputReady(actionId, packageId, stdOut, ok) {
            if ((actionId === "deps" || actionId === "depends")
                && root.hasPackage && packageId === root.pkg.packageId) {
                root.depsOutput = stdOut.length > 0 ? stdOut
                                                    : qsTr("No dependencies reported")
            }
        }
    }
}
