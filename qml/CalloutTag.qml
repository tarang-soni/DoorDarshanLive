import QtQuick
import QtQuick.Shapes

// Label box with its top-right corner cut off, like a HUD callout.
Item {
    id: root

    property string text: ""
    property color tone: Theme.text
    property real chamfer: 8
    property bool filled: true
    property int fontSize: 12

    implicitWidth: label.implicitWidth + 26
    implicitHeight: label.implicitHeight + 12

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: root.tone
            strokeWidth: 1
            fillColor: root.filled ? Qt.rgba(0.02, 0.03, 0.03, 0.82) : "transparent"
            joinStyle: ShapePath.MiterJoin
            startX: 0.5; startY: 0.5
            PathLine { x: root.width - root.chamfer; y: 0.5 }
            PathLine { x: root.width - 0.5; y: root.chamfer }
            PathLine { x: root.width - 0.5; y: root.height - 0.5 }
            PathLine { x: 0.5; y: root.height - 0.5 }
            PathLine { x: 0.5; y: 0.5 }
        }
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        x: 11
        text: root.text
        color: root.tone
        font.family: Theme.fontMono
        font.pixelSize: root.fontSize
        font.letterSpacing: 0.8
        font.capitalization: Font.AllUppercase
    }
}
