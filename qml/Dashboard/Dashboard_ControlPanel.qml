import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
ColumnLayout {

    spacing: 8

    Label {
        text: "[Control Panel]"
        color: Theme.normal_text_theme_color
        font.family: Theme.jetbrainsFont
        font.pixelSize: 15
    }
    Rectangle{
        Layout.preferredWidth: 180
        Layout.fillHeight: true
        color: Theme.primary_theme_color
        border.width: 1
        border.color: Theme.border_theme_color

        ColumnLayout
        {
            anchors.fill: parent
            anchors.margins: 20
            spacing:10
            SidebarButton{
                Layout.fillWidth: true
                Layout.preferredHeight:40
                text:"Refresh"
                fontSize:15
                color:"transparent"
            }
            SidebarButton{
                Layout.fillWidth: true
                Layout.preferredHeight:40
                text:"Camera : ON"
                fontSize:15
                color:"transparent"
            }
            SidebarButton{
                Layout.fillWidth: true
                Layout.preferredHeight:40
                text:"Motion : ON"
                fontSize:15
                color:"transparent"

            }
            SidebarButton{
                Layout.fillWidth: true
                Layout.preferredHeight:40
                text:"Snapshot"
                fontSize:15
                color:"transparent"

            }
            SidebarButton{
                Layout.fillWidth: true
                Layout.preferredHeight:40
                text:"Reconnect"
                fontSize:15
                color:"transparent"

            }

        }
    }
}