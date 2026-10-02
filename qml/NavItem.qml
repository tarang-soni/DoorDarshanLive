import QtQuick

Item {
    id: root

    property string label: ""
    property string iconName: ""
    property int number: 0
    property bool selected: false

    signal clicked()

    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        color: root.selected ? Theme.tint(Theme.accent, 0.08)
                             : mouse.containsMouse ? Theme.tint("white", 0.03) : "transparent"
        border.width: root.selected ? 1 : 0
        border.color: Theme.tint(Theme.accent, 0.3)
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.selected ? 2 : 0
        color: Theme.accent
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Theme.pad(root.number, 2)
            color: root.selected ? Theme.accent : Theme.textFaint
            font.family: Theme.fontMono
            font.pixelSize: 11
        }
        AppIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            color: root.selected ? Theme.accent : mouse.containsMouse ? Theme.text : Theme.textMuted
            size: 17
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.selected ? Theme.text : mouse.containsMouse ? Theme.text : Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: 13
            font.letterSpacing: 1.2
            font.capitalization: Font.AllUppercase
        }
    }

    Text {
        visible: root.selected
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: "◂"
        color: Theme.accent
        font.family: Theme.fontMono
        font.pixelSize: 12
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
