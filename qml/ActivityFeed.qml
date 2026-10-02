import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Session log: timestamp, event tag and message, newest first.
Item {
    id: root

    ListView {
        id: list
        anchors.fill: parent
        clip: true
        spacing: 10
        model: Session.activity
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220 }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: 180; easing.type: Easing.OutCubic }
        }

        delegate: ColumnLayout {
            id: entry
            required property string text
            required property string kind
            required property string tag
            required property double at

            width: list.width
            spacing: 3

            RowLayout {
                spacing: 10
                Text {
                    text: Qt.formatDateTime(new Date(entry.at), "hh:mm:ss")
                    color: Theme.textFaint
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                }
                Text {
                    Layout.fillWidth: true
                    text: entry.tag
                    color: Theme.tone(entry.kind)
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
            Text {
                Layout.fillWidth: true
                text: entry.text
                color: Theme.text
                font.family: Theme.fontMono
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }

    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        visible: list.count === 0
        text: "> waiting for events_"
        color: Theme.textFaint
        font.family: Theme.fontMono
        font.pixelSize: 12
    }
}
