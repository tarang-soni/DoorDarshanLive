import QtQuick

// Row of bars where the first `value * segments` are lit, like a signal meter.
Row {
    id: root

    property real value: 0
    property int segments: 16
    property real segmentWidth: 5
    property real segmentHeight: 14
    property color tone: Theme.accent
    property bool animated: false

    readonly property int lit: Math.round(Math.max(0, Math.min(1, value)) * segments)

    spacing: 2

    Repeater {
        model: root.segments
        Rectangle {
            required property int index
            width: root.segmentWidth
            height: root.segmentHeight
            color: index < root.lit ? root.tone : Theme.tint(root.tone, 0.16)
            Behavior on color { enabled: root.animated; ColorAnimation { duration: 90 } }
        }
    }
}
