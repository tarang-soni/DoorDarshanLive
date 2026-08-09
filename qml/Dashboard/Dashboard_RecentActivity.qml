import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ".."
ColumnLayout {

    spacing: 8

    HeadingText {
        headingTxt: "Recent Activity"
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