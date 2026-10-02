import QtQuick
import QtQuick.Layouts

// Stack of short-lived notifications in the bottom-right corner.
Item {
    id: root

    function show(message, kind) {
        toasts.append({ message: message, kind: kind || "info" })
    }

    ListModel { id: toasts }

    ListView {
        id: list
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 24
        }
        width: 400
        height: contentHeight
        spacing: 8
        interactive: false
        verticalLayoutDirection: ListView.BottomToTop
        model: toasts

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 160 }
                NumberAnimation { property: "x"; from: 30; to: 0; duration: 220; easing.type: Easing.OutCubic }
            }
        }
        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 160 }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: 180; easing.type: Easing.OutCubic }
        }

        delegate: Rectangle {
            id: toast
            required property int index
            required property string message
            required property string kind
            readonly property color tone: Theme.tone(kind)
            readonly property string prefix: {
                switch (kind) {
                case "success": return "[ OK ]"
                case "danger": return "[ERR ]"
                case "warning": return "[WARN]"
                default: return "[INFO]"
                }
            }

            width: list.width
            height: row.implicitHeight + 22
            radius: 0
            color: Theme.surfaceRaised
            border.width: 1
            border.color: Theme.tint(tone, 0.45)

            Rectangle {
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: 2
                color: toast.tone
            }

            RowLayout {
                id: row
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 16
                    rightMargin: 14
                }
                spacing: 12

                Text {
                    Layout.alignment: Qt.AlignTop
                    text: toast.prefix
                    color: toast.tone
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: toast.message
                    color: Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: toasts.remove(toast.index)
            }

            Timer {
                interval: 3600
                running: true
                onTriggered: toasts.remove(toast.index)
            }
        }
    }
}
