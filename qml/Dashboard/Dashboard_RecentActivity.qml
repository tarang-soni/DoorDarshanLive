import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
ColumnLayout {

    spacing: 8

    Label {
        text: "[Recent Activity]"
        color: Theme.normal_text_theme_color
        font.family: Theme.jetbrainsFont
        font.pixelSize: 15
    }

    Rectangle{
        id:recentActivity
        Layout.fillWidth: true
        Layout.fillHeight: true

        color:Theme.primary_theme_color
        border.color:Theme.border_theme_color
        border.width:1
    }
}