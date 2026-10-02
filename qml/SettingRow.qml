import QtQuick
import QtQuick.Layouts

// One labelled row in a settings panel; the control goes on the right.
Item {
    id: root

    property string title: ""
    property string description: ""
    property string iconName: ""
    property bool divider: true
    default property alias control: controlSlot.data

    implicitHeight: Math.max(row.implicitHeight, 40) + 24
    width: parent ? parent.width : 0

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        Rectangle {
            visible: root.iconName !== ""
            implicitWidth: 34
            implicitHeight: 34
            radius: 0
            color: "transparent"
            border.width: 1
            border.color: Theme.border
            AppIcon {
                anchors.centerIn: parent
                name: root.iconName
                color: Theme.textMuted
                size: 16
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.text
                font.family: Theme.fontMono
                font.pixelSize: 13
                font.letterSpacing: 0.4
            }
            Text {
                visible: root.description !== ""
                Layout.fillWidth: true
                text: root.description
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }
        }
        Row {
            id: controlSlot
            Layout.alignment: Qt.AlignVCenter
            spacing: 8
        }
    }

    // Dashed divider
    Row {
        visible: root.divider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 4
        clip: true
        Repeater {
            model: Math.ceil(root.width / 8)
            Rectangle { width: 4; height: 1; color: Theme.borderStrong }
        }
    }
}
