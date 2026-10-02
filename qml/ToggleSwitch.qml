import QtQuick
import QtQuick.Controls.Basic

// Square track with a square knob.
Switch {
    id: control

    hoverEnabled: true
    padding: 0
    spacing: 0
    implicitWidth: indicator.implicitWidth
    implicitHeight: indicator.implicitHeight

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    indicator: Rectangle {
        implicitWidth: 40
        implicitHeight: 20
        x: control.leftPadding
        y: (control.height - height) / 2
        radius: 0
        color: control.checked ? Theme.tint(Theme.accent, 0.16) : "transparent"
        border.width: 1
        border.color: control.checked ? Theme.accent : control.hovered ? Theme.textMuted : Theme.borderStrong
        Behavior on color { ColorAnimation { duration: Theme.durationNormal } }

        Rectangle {
            width: 12
            height: 12
            y: 4
            x: control.checked ? parent.width - width - 4 : 4
            radius: 0
            color: control.checked ? Theme.accent : Theme.textFaint
            Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Theme.durationNormal } }
        }
    }

    contentItem: Item {}
}
