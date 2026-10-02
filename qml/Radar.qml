import QtQuick

// Expanding rings and a sweeping arm around an icon, shown while scanning.
Item {
    id: root

    property color tone: Theme.accent
    property string iconName: "wifi"
    property real size: 150

    implicitWidth: size
    implicitHeight: size

    // Static range rings + crosshair
    Repeater {
        model: 3
        Rectangle {
            required property int index
            anchors.centerIn: parent
            width: root.size * (index + 1) / 3
            height: width
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: Theme.tint(root.tone, 0.18)
        }
    }
    Rectangle { anchors.centerIn: parent; width: root.size; height: 1; color: Theme.tint(root.tone, 0.12) }
    Rectangle { anchors.centerIn: parent; width: 1; height: root.size; color: Theme.tint(root.tone, 0.12) }

    // Sweep
    Item {
        anchors.fill: parent
        Rectangle {
            x: root.size / 2
            y: root.size / 2 - 0.5
            width: root.size / 2
            height: 1
            color: root.tone
        }
        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: 2400
            loops: Animation.Infinite
            running: root.visible
        }
    }

    Rectangle {
        id: ping
        anchors.centerIn: parent
        width: root.size
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: root.tone
        scale: 0.2
        opacity: 0
        ParallelAnimation {
            running: root.visible
            loops: Animation.Infinite
            NumberAnimation { target: ping; property: "scale"; from: 0.2; to: 1; duration: 2400; easing.type: Easing.OutCubic }
            NumberAnimation { target: ping; property: "opacity"; from: 0.7; to: 0; duration: 2400 }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 44
        height: 44
        color: Theme.bg
        border.width: 1
        border.color: root.tone
        AppIcon {
            anchors.centerIn: parent
            name: root.iconName
            color: root.tone
            size: 20
        }
    }
}
