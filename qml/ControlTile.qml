import QtQuick
import QtQuick.Layouts

// Large toggle panel: icon frame, label, state and a switch. The whole tile is clickable.
Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property bool checked: false
    property color tone: Theme.accent

    signal toggled()

    implicitHeight: 76
    radius: 0
    color: checked ? Theme.tint(tone, 0.05) : Theme.surface
    border.width: 1
    border.color: checked ? Theme.tint(tone, 0.6) : mouse.containsMouse ? Theme.borderStrong : Theme.border

    Behavior on color { ColorAnimation { duration: Theme.durationNormal } }
    Behavior on border.color { ColorAnimation { duration: Theme.durationNormal } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        Item {
            implicitWidth: 44
            implicitHeight: 44
            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                color: Theme.tint(root.tone, root.checked ? 0.12 : 0.03)
                border.width: 1
                border.color: Theme.tint(root.checked ? root.tone : Theme.textMuted, 0.25)
            }
            Brackets {
                visible: root.checked
                color: root.tone
                length: 8
            }
            AppIcon {
                anchors.centerIn: parent
                name: root.iconName
                color: root.checked ? root.tone : Theme.textMuted
                size: 20
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: 11
                font.letterSpacing: Theme.labelSpacing
                font.capitalization: Font.AllUppercase
            }
            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: root.checked ? root.tone : Theme.text
                font.family: Theme.fontMono
                font.pixelSize: 14
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
            }
        }
        ToggleSwitch {
            checked: root.checked
        }
    }

    // Sits above the switch so clicks always go through toggled(),
    // keeping `checked` bound to the backend state.
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
