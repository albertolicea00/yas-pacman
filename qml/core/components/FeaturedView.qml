import QtQuick
import QtQuick.Controls.Basic
import Yas.Core

// Store-like discovery grid shown in Explore before the first search.
// Loads categories of featured packages from YasManager.featuredUrl (the
// future yas-web API) or, while empty, from the bundled mock at
// qrc:/yas/featured.json. Expected JSON:
//   { "categories": [ { "name": "Browsers", "packages": [
//       { "id": "firefox", "name": "Firefox", "description": "...",
//         "kind": "cask" } ] } ] }
Flickable {
    id: root
    signal packageTapped(string packageId, string kind)

    property var categories: []

    contentHeight: content.height + 20
    clip: true
    ScrollBar.vertical: ScrollBar {}

    function load() {
        if (YasManager.featuredUrl.length === 0) {
            // Bundled mock, read through C++ (QML XHR cannot access qrc).
            try {
                root.categories =
                    JSON.parse(YasManager.bundledFeaturedJson()).categories || []
            } catch (e) {
                root.categories = []
            }
            return
        }
        const xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            try {
                root.categories = JSON.parse(xhr.responseText).categories || []
            } catch (e) {
                root.categories = []
            }
        }
        xhr.open("GET", YasManager.featuredUrl)
        xhr.send()
    }

    Component.onCompleted: load()
    Connections {
        target: YasManager
        function onFeaturedUrlChanged() { root.load() }
    }

    Column {
        id: content
        width: root.width
        spacing: 16

        Text {
            visible: root.categories.length > 0
            text: qsTr("Discover")
            color: Theme.textPrimary
            font.family: Theme.headingFont
            font.pixelSize: Theme.fs(16)
            font.weight: Font.Bold
        }

        Repeater {
            model: root.categories
            delegate: Column {
                required property var modelData
                width: content.width
                spacing: 8

                Text {
                    text: modelData.name
                    color: Theme.textSecondary
                    font.family: Theme.uiFont
                    font.pixelSize: Theme.fs(12)
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                }

                Flow {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: modelData.packages
                        delegate: Rectangle {
                            required property var modelData
                            width: Math.min(228, content.width)
                            height: 64
                            radius: Theme.radius
                            color: cardHover.hovered ? Theme.surfaceAlt : Theme.base
                            border.color: Theme.border

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Rectangle {
                                    width: 34; height: 34; radius: 17
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Theme.accentSubtle
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.name.charAt(0).toUpperCase()
                                        color: Theme.accent
                                        font.family: Theme.uiFont
                                        font.pixelSize: Theme.fs(15)
                                        font.weight: Font.Bold
                                    }
                                }

                                Column {
                                    width: parent.width - 34 - 8 - 26
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    Text {
                                        width: parent.width
                                        text: modelData.name
                                        color: Theme.textPrimary
                                        font.family: Theme.uiFont
                                        font.pixelSize: Theme.fs(13)
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.description || modelData.id
                                        color: Theme.textSecondary
                                        font.family: Theme.uiFont
                                        font.pixelSize: Theme.fs(11)
                                        elide: Text.ElideRight
                                    }
                                }

                                IconButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    icon: "+"
                                    tint: Theme.accent
                                    tooltip: qsTr("Install %1").arg(modelData.id)
                                    onClicked: App.install(modelData.id,
                                                           modelData.kind || "")
                                }
                            }

                            HoverHandler { id: cardHover }
                            TapHandler {
                                onTapped: root.packageTapped(modelData.id,
                                                             modelData.kind || "")
                            }
                        }
                    }
                }
            }
        }
    }
}
