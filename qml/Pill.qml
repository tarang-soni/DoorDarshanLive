import QtQuick

// Small square-cornered status tag tinted with `tone`.
Rectangle {
    id: root

    property string text: ""
    property color tone: Theme.accent
    property string iconName: ""
    property bool dot: false
    property bool pulsing: false
    property bool mono: true
    property bool solid: false

    implicitHeight: 22
    implicitWidth: row.implicitWidth + 16
    radius: 0
    color: solid ? Qt.rgba(0.02, 0.03, 0.03, 0.82) : Theme.tint(tone, 0.08)
    border.width: 1
    border.color: Theme.tint(tone, solid ? 0.55 : 0.4)

    Behavior on color { ColorAnimation { duration: Theme.durationNormal } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        StatusDot {
            visible: root.dot
            anchors.verticalCenter: parent.verticalCenter
            color: root.tone
            pulsing: root.pulsing
            size: 6
        }
        AppIcon {
            visible: root.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            color: root.tone
            size: 13
            strokeWidth: 2
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.tone
            font.family: Theme.fontMono
            font.pixelSize: 11
            font.letterSpacing: 1
            font.capitalization: Font.AllUppercase
        }
    }
}
