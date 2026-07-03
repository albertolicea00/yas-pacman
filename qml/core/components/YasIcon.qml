import QtQuick
import QtQuick.Shapes
import Yas.Core

// Uniform stroke icons (24x24 viewBox, Feather-style paths) so the nav never
// depends on inconsistent unicode glyphs. Unknown names fall back to
// rendering the name itself as a text glyph (used by app extraViews).
Item {
    id: root
    property string name: ""
    property color color: Theme.textSecondary
    property real size: Theme.fs(20)

    readonly property var paths: ({
        "home": "M3 10.5 12 3l9 7.5V20a1.6 1.6 0 0 1-1.6 1.6H4.6A1.6 1.6 0 0 1 3 20z M9.4 21.6V13h5.2v8.6",
        "search": "M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14z M20.6 20.6l-4.4-4.4",
        "box": "M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z M3.3 7 12 12l8.7-5 M12 22V12",
        "refresh": "M23 4v6h-6 M20.49 15a9 9 0 1 1-2.12-9.36L23 10",
        "tools": "M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z",
        "settings": "M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33h.01a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51h.01a1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82v.01a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z",
        "tap": "M6 3v12 M18 9a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M6 21a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M18 9a9 9 0 0 1-9 9",
    })
    readonly property bool known: paths[name] !== undefined

    width: size
    height: size

    Shape {
        visible: root.known
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        transform: Scale { xScale: root.width / 24; yScale: root.height / 24 }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.9
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.known ? root.paths[root.name] : "" }
        }
    }

    Text {
        visible: !root.known
        anchors.centerIn: parent
        text: root.name
        color: root.color
        font.pixelSize: Math.round(root.size * 0.9)
    }
}
