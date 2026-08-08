import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

RowLayout {
    id: root

    property string label: ""
    property string value: ""
    property color valueColor: "#6FCF97"
    property int textSpacing:70

    Layout.fillWidth: true
    spacing: 8

    Label {
        text: root.label
        Layout.preferredWidth: textSpacing

        color: Theme.normal_text_theme_color
        font.family: Theme.jetbrainsFont
        font.pixelSize: 13

        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }


    Label {
        text: ":"
        Layout.preferredWidth: 12

        color: Theme.normal_text_theme_color
        font.family: Theme.jetbrainsFont
        font.pixelSize: 13

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Label {
        text: root.value
        Layout.fillWidth: true

        color: root.valueColor
        font.family: Theme.jetbrainsFont
        font.pixelSize: 13

        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }
}