import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string iconName: "sparkle"
    property string title: ""
    property string message: ""
    property color tone: Theme.accent
    default property alias actions: actionRow.data

    spacing: 0

    Item {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: 76
        implicitHeight: 76

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            color: Theme.tint(root.tone, 0.06)
            border.width: 1
            border.color: Theme.tint(root.tone, 0.25)
        }
        Brackets {
            color: root.tone
            length: 12
        }
        AppIcon {
            anchors.centerIn: parent
            name: root.iconName
            color: root.tone
            size: 28
            strokeWidth: 1.6
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20
        text: root.title
        color: Theme.text
        font.family: Theme.fontMono
        font.pixelSize: 15
        font.letterSpacing: 1.6
        font.capitalization: Font.AllUppercase
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 8
        Layout.maximumWidth: 400
        visible: root.message !== ""
        text: root.message
        color: Theme.textMuted
        font.family: Theme.fontMono
        font.pixelSize: 12
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        lineHeight: 1.25
    }
    Row {
        id: actionRow
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: children.length > 0 ? 22 : 0
        spacing: 10
    }
}
