import QtQuick
import QtQuick.Controls.Basic

// Square terminal button.
// variant: "primary" (solid mint), "secondary" (outlined), "ghost" (text only), "danger"
Button {
    id: control

    property string iconName: ""
    property string variant: "secondary"
    property bool busy: false
    property bool compact: false

    readonly property bool iconOnly: text === ""
    readonly property color foreground: {
        switch (variant) {
        case "primary": return "#04110E"
        case "danger": return Theme.danger
        case "ghost": return hovered ? Theme.text : Theme.textMuted
        default: return hovered ? Theme.accent : Theme.text
        }
    }

    implicitHeight: compact ? 30 : 36
    implicitWidth: iconOnly ? implicitHeight : contentItem.implicitWidth + leftPadding + rightPadding
    leftPadding: iconOnly ? 0 : (compact ? 12 : 16)
    rightPadding: leftPadding
    hoverEnabled: true
    opacity: enabled ? 1 : 0.4

    font.family: Theme.fontMono
    font.pixelSize: compact ? 11 : 12
    font.weight: Font.DemiBold
    font.letterSpacing: 1.2
    font.capitalization: Font.AllUppercase

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8

            BusySpinner {
                visible: control.busy
                anchors.verticalCenter: parent.verticalCenter
                size: control.compact ? 12 : 14
                color: control.foreground
            }
            AppIcon {
                visible: control.iconName !== "" && !control.busy
                anchors.verticalCenter: parent.verticalCenter
                name: control.iconName
                size: control.compact ? 14 : 16
                color: control.foreground
                strokeWidth: 2
            }
            Text {
                visible: !control.iconOnly
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
                font: control.font
                color: control.foreground
            }
        }
    }

    background: Rectangle {
        radius: 0
        border.width: control.variant === "ghost" ? 0 : 1
        border.color: {
            switch (control.variant) {
            case "primary": return Theme.accent
            case "danger": return Theme.tint(Theme.danger, control.hovered ? 0.8 : 0.45)
            default: return control.hovered ? Theme.accent : Theme.borderStrong
            }
        }
        color: {
            switch (control.variant) {
            case "primary": return control.down ? Qt.darker(Theme.accent, 1.2) : control.hovered ? Qt.lighter(Theme.accent, 1.12) : Theme.accent
            case "danger": return Theme.tint(Theme.danger, control.hovered ? 0.14 : 0.05)
            case "ghost": return control.hovered ? Theme.tint("white", 0.05) : "transparent"
            default: return control.down ? Theme.tint(Theme.accent, 0.14) : control.hovered ? Theme.tint(Theme.accent, 0.07) : "transparent"
            }
        }
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
    }
}
