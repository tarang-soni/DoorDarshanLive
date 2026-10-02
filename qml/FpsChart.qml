import QtQuick
import QtQuick.Shapes

// Line + area chart of the last minute of frame rates, over a grid.
Rectangle {
    id: root

    property var samples: []
    property real ceiling: 30
    property color tone: Theme.accent

    readonly property real scaleMax: Math.max(ceiling, Math.max.apply(null, samples.concat([0])))
    readonly property var points: {
        const n = samples.length
        const pts = []
        if (n === 0)
            return pts
        const step = n > 1 ? width / (n - 1) : 0
        for (let i = 0; i < n; ++i)
            pts.push(Qt.point(i * step, height - 2 - (samples[i] / scaleMax) * (height - 8)))
        return pts
    }

    color: Theme.surfaceSunken
    border.width: 1
    border.color: Theme.border
    clip: true

    // Grid
    Repeater {
        model: 3
        Rectangle {
            required property int index
            x: 0
            y: (index + 1) * root.height / 4
            width: root.width
            height: 1
            color: Theme.grid
        }
    }
    Repeater {
        model: 7
        Rectangle {
            required property int index
            x: (index + 1) * root.width / 8
            y: 0
            width: 1
            height: root.height
            color: Theme.grid
        }
    }

    Shape {
        anchors.fill: parent
        visible: root.points.length > 1
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: 0; y1: 0; x2: 0; y2: root.height
                GradientStop { position: 0; color: Theme.tint(root.tone, 0.28) }
                GradientStop { position: 1; color: Theme.tint(root.tone, 0.0) }
            }
            PathPolyline {
                path: root.points.length > 1
                      ? root.points.concat([Qt.point(root.width, root.height), Qt.point(0, root.height)])
                      : []
            }
        }
        ShapePath {
            strokeColor: root.tone
            strokeWidth: 1.5
            fillColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            PathPolyline { path: root.points }
        }
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 4
        text: Math.round(root.scaleMax)
        color: Theme.textFaint
        font.family: Theme.fontMono
        font.pixelSize: 9
    }
}
