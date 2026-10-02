import QtQuick

// Four L-shaped corner ticks framing the parent area (HUD targeting frame).
Item {
    id: root

    property color color: Theme.accent
    property real length: 10
    property real thickness: 1.5

    anchors.fill: parent

    // top-left
    Rectangle { x: 0; y: 0; width: root.length; height: root.thickness; color: root.color }
    Rectangle { x: 0; y: 0; width: root.thickness; height: root.length; color: root.color }
    // top-right
    Rectangle { x: root.width - root.length; y: 0; width: root.length; height: root.thickness; color: root.color }
    Rectangle { x: root.width - root.thickness; y: 0; width: root.thickness; height: root.length; color: root.color }
    // bottom-left
    Rectangle { x: 0; y: root.height - root.thickness; width: root.length; height: root.thickness; color: root.color }
    Rectangle { x: 0; y: root.height - root.length; width: root.thickness; height: root.length; color: root.color }
    // bottom-right
    Rectangle { x: root.width - root.length; y: root.height - root.thickness; width: root.length; height: root.thickness; color: root.color }
    Rectangle { x: root.width - root.thickness; y: root.height - root.length; width: root.thickness; height: root.length; color: root.color }
}
