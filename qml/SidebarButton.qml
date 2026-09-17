import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
Rectangle {
    id: root

    implicitWidth: 150
    implicitHeight: 60

    color: Theme.primary_theme_color

    property string text: ""
    property bool isSelected: false
    property int fontSize: 20
    property bool hovered: false

    scale: hovered ? 1.05 : 1.0
    signal clicked()
    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutQuad
        }
    }
    Label {
        text: "["
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        color: root.isSelected ? Theme.selectedBtn_text_theme_color
                               : Theme.normal_text_theme_color
        font.family: Theme.jetbrainsFont
        font.pixelSize: root.fontSize
    }

    Label {
        text: root.text
        anchors.centerIn: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: root.isSelected ? Theme.selectedBtn_text_theme_color
                               : Theme.normal_text_theme_color
        font.family: Theme.jetbrainsFont
        font.pixelSize: root.fontSize
    }

    Label {
        text: "]"
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        color: root.isSelected ? Theme.selectedBtn_text_theme_color
                               : Theme.normal_text_theme_color
        font.family: Theme.jetbrainsFont
        font.pixelSize: root.fontSize
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: root.clicked()
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }
}