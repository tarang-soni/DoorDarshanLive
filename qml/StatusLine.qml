import QtQuick
import QtQuick.Layouts

// "LABEL      : value" row, terminal-style.
RowLayout {
    id: root

    property string label: ""
    property string value: ""
    property color tone: Theme.textFaint
    property bool pulsing: false
    property bool mono: true
    property real labelWidth: 110

    spacing: 8
    width: parent ? parent.width : 0

    StatusDot {
        color: root.tone
        pulsing: root.pulsing
        size: 6
    }
    Text {
        Layout.preferredWidth: root.labelWidth
        text: root.label
        color: Theme.textMuted
        font.family: Theme.fontMono
        font.pixelSize: 12
        font.letterSpacing: 1
        font.capitalization: Font.AllUppercase
    }
    Text {
        text: ":"
        color: Theme.textFaint
        font.family: Theme.fontMono
        font.pixelSize: 12
    }
    Text {
        Layout.fillWidth: true
        text: root.value
        color: root.tone === Theme.textFaint ? Theme.textMuted : Theme.text
        font.family: Theme.fontMono
        font.pixelSize: 12
        elide: Text.ElideRight
    }
}
