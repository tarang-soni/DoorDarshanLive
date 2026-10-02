import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Modal panel with a title, message, custom body and confirm/cancel buttons.
Popup {
    id: root

    property string title: ""
    property string message: ""
    property string iconName: "info"
    property color tone: Theme.accent
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool destructive: false
    property bool confirmEnabled: true
    default property alias body: bodySlot.data

    signal confirmed()

    parent: Overlay.overlay
    anchors.centerIn: parent
    width: 460
    padding: 24
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.72)
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140 }
            NumberAnimation { property: "y"; from: root.y + 8; to: root.y; duration: 180; easing.type: Easing.OutCubic }
        }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; to: 0; duration: 100 }
    }

    background: Rectangle {
        radius: 0
        color: Theme.surface
        border.width: 1
        border.color: Theme.borderStrong
        Brackets {
            color: root.tone
            length: 14
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            spacing: 10
            AppIcon {
                name: root.iconName
                color: root.tone
                size: 16
                strokeWidth: 2
            }
            Text {
                Layout.fillWidth: true
                text: root.destructive ? "// confirm action" : "// input required"
                color: Theme.textFaint
                font.family: Theme.fontMono
                font.pixelSize: 11
            }
        }
        Text {
            Layout.topMargin: 14
            Layout.fillWidth: true
            text: root.title
            color: Theme.text
            font.family: Theme.fontMono
            font.pixelSize: 17
            font.letterSpacing: 1.2
            font.capitalization: Font.AllUppercase
            wrapMode: Text.WordWrap
        }
        Text {
            Layout.topMargin: 8
            Layout.fillWidth: true
            visible: root.message !== ""
            text: root.message
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            lineHeight: 1.25
        }
        ColumnLayout {
            id: bodySlot
            Layout.fillWidth: true
            Layout.topMargin: children.length > 0 ? 18 : 0
            spacing: 12
        }
        RowLayout {
            Layout.topMargin: 24
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }
            AppButton {
                text: root.cancelText
                variant: "ghost"
                onClicked: root.close()
            }
            AppButton {
                text: root.confirmText
                variant: root.destructive ? "danger" : "primary"
                enabled: root.confirmEnabled
                onClicked: {
                    root.confirmed()
                    root.close()
                }
            }
        }
    }
}
