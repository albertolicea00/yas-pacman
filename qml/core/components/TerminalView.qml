import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// "Smart Terminal Output View": live stream of the exact CLI commands and
// their output. Collapsible bottom panel.
Rectangle {
    id: root
    property bool expanded: false
    readonly property int headerHeight: 34

    color: Theme.terminalBase
    border.color: Theme.border
    height: expanded ? 240 : headerHeight
    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    function append(line, isError) {
        lines.append({ line: line, error: isError })
        if (lines.count > 2000)
            lines.remove(0, lines.count - 2000)
        output.positionViewAtEnd()
    }

    ListModel { id: lines }

    Connections {
        target: App
        function onTerminalOutput(line, isStdErr) { root.append(line, isStdErr) }
        function onCommandStarted(commandLine) {
            root.append("$ " + commandLine, false)
            if (YasManager.terminalAutoExpand)
                root.expanded = true
        }
        function onCommandFinished(exitCode) {
            if (exitCode !== 0)
                root.append(qsTr("[exit code %1]").arg(exitCode), true)
        }
    }

    Rectangle {
        id: header
        width: parent.width
        height: root.headerHeight
        color: Theme.surface

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: root.expanded ? "▾" : "▸"
                color: Theme.textSecondary
                font.pixelSize: Theme.fs(12)
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: qsTr("Terminal")
                color: Theme.textPrimary
                font.family: Theme.uiFont
                font.pixelSize: Theme.fs(12)
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible: App.queue.busy
                text: App.queue.currentKind
                      + (App.queue.pendingCount > 0
                         ? qsTr(" (+%1 queued)").arg(App.queue.pendingCount) : "")
                color: Theme.accent
                font.family: Theme.monoFont
                font.pixelSize: Theme.fs(11)
                anchors.verticalCenter: parent.verticalCenter
            }
            BusyIndicator {
                visible: App.queue.busy
                running: visible
                width: 16; height: 16
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            IconButton {
                visible: App.queue.busy
                icon: "⊘"
                label: qsTr("Cancel")
                tint: Theme.danger
                anchors.verticalCenter: parent.verticalCenter
                onClicked: App.queue.cancelCurrent()
            }
            IconButton {
                icon: "⌫"
                label: qsTr("Clear")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: lines.clear()
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: 160  // keep buttons clickable
            onClicked: root.expanded = !root.expanded
            cursorShape: Qt.PointingHandCursor
        }
    }

    ListView {
        id: output
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        visible: root.expanded
        clip: true
        model: lines
        delegate: Text {
            width: output.width
            text: model.line
            color: model.error ? Theme.danger
                               : model.line.startsWith("$ ") ? Theme.accent : Theme.textSecondary
            font.family: Theme.monoFont
            font.pixelSize: Theme.fs(12)
            wrapMode: Text.WrapAnywhere
            textFormat: Text.PlainText
        }
        ScrollBar.vertical: ScrollBar {}
    }
}
