import QtQuick
import QtQuick.Layouts

// Prompt-style page title: ~/doordarshan/<path>, big uppercase title with a
// blinking block cursor, and a "// comment" subtitle.
RowLayout {
    id: root

    property string title: ""
    property string subtitle: ""
    property string path: ""
    default property alias trailing: trailingRow.data

    spacing: 16

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Text {
            Layout.fillWidth: true
            text: "~/doordarshan/" + root.path
            color: Theme.textFaint
            font.family: Theme.fontMono
            font.pixelSize: 11
            font.letterSpacing: 0.6
        }
        Row {
            spacing: 10
            Text {
                id: titleText
                text: root.title
                color: Theme.text
                font.family: Theme.fontMono
                font.pixelSize: 30
                font.weight: Font.Light
                font.letterSpacing: 2
                font.capitalization: Font.AllUppercase
            }
            Rectangle {
                anchors.bottom: titleText.baseline
                width: 13
                height: 24
                color: Theme.accent
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1; duration: 0 }
                    PauseAnimation { duration: 560 }
                    NumberAnimation { to: 0; duration: 0 }
                    PauseAnimation { duration: 560 }
                }
            }
        }
        Text {
            visible: root.subtitle !== ""
            Layout.fillWidth: true
            text: "// " + root.subtitle
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    Row {
        id: trailingRow
        spacing: 8
        Layout.alignment: Qt.AlignBottom
    }
}
