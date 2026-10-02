import QtQuick

// A coloured dot that can emit a soft "radar" pulse to show something is live.
Item {
    id: root

    property color color: Theme.success
    property bool pulsing: false
    property real size: 8

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: ring
        anchors.centerIn: parent
        width: root.size
        height: root.size
        radius: width / 2
        color: root.color
        opacity: 0
        visible: root.pulsing

        ParallelAnimation {
            running: root.pulsing && root.visible
            loops: Animation.Infinite
            NumberAnimation { target: ring; property: "scale"; from: 1; to: 2.8; duration: 1400; easing.type: Easing.OutCubic }
            NumberAnimation { target: ring; property: "opacity"; from: 0.55; to: 0; duration: 1400; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.color
        Behavior on color { ColorAnimation { duration: Theme.durationNormal } }
    }
}
