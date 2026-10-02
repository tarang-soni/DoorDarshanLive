import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real size: 18
    property color color: Theme.text
    property real lineWidth: 2

    implicitWidth: size
    implicitHeight: size

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: Theme.tint(root.color, 0.18)
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.size / 2 - root.lineWidth
                radiusY: root.size / 2 - root.lineWidth
                startAngle: 0
                sweepAngle: 360
            }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.size / 2 - root.lineWidth
                radiusY: root.size / 2 - root.lineWidth
                startAngle: -90
                sweepAngle: 110
            }
        }

        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
            running: root.visible
        }
    }
}
