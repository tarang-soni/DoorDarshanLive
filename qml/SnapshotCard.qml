import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int entryId: -1
    property string imagePath: ""
    property string visitorName: ""
    property bool isKnown: false
    property string iso: ""
    property string timestamp: ""

    signal nameRequested()
    signal deleteRequested()
    signal previewRequested()

    readonly property double atMs: iso !== "" ? Date.parse(iso) : NaN
    readonly property color tone: isKnown ? Theme.success : Theme.warning

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: 7
        radius: 0
        color: Theme.surface
        border.width: 1
        border.color: hover.hovered ? Theme.tint(root.tone, 0.5) : Theme.border
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        HoverHandler { id: hover }

        // Header strip
        RowLayout {
            id: strip
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            height: 18
            Text {
                Layout.fillWidth: true
                text: "REC-" + Theme.pad(root.entryId, 4)
                color: Theme.textFaint
                font.family: Theme.fontMono
                font.pixelSize: 10
                font.letterSpacing: 1
            }
            Pill {
                text: root.isKnown ? "Known" : "Unknown"
                tone: root.tone
                dot: true
            }
        }

        RoundedImage {
            id: thumb
            anchors { left: parent.left; right: parent.right; top: strip.bottom; leftMargin: 10; rightMargin: 10; topMargin: 8 }
            height: width * 0.56
            source: Theme.fileUrl(root.imagePath)

            Brackets {
                visible: hover.hovered
                color: root.tone
                length: 14
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: thumbMouse.containsMouse ? 0.45 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
                Text {
                    anchors.centerIn: parent
                    text: "[ VIEW ]"
                    color: Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                    font.letterSpacing: 1.6
                    opacity: thumbMouse.containsMouse ? 1 : 0
                }
            }
            MouseArea {
                id: thumbMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.previewRequested()
            }
        }

        RowLayout {
            anchors { left: parent.left; right: parent.right; top: thumb.bottom; bottom: parent.bottom; leftMargin: 12; rightMargin: 8 }
            spacing: 6

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    Layout.fillWidth: true
                    text: root.isKnown ? root.visitorName : "Unknown visitor"
                    color: root.isKnown ? Theme.text : Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 13
                    font.letterSpacing: 0.6
                    font.capitalization: Font.AllUppercase
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: isNaN(root.atMs) ? root.timestamp
                                           : Qt.formatDateTime(new Date(root.atMs), "dd MMM · hh:mm:ss") + "  (" + Session.relativeTime(root.atMs) + ")"
                    color: Theme.textFaint
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
            }
            AppButton {
                visible: !root.isKnown
                compact: true
                variant: "secondary"
                text: "Name"
                onClicked: root.nameRequested()
            }
            AppButton {
                compact: true
                variant: "ghost"
                iconName: "trash"
                onClicked: root.deleteRequested()
            }
        }
    }
}
