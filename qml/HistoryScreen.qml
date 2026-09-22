import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"
PageFrame{
    id: root
    headerContent:HeadingText{
        font.pixelSize:24
        headingTxt:"History"
        anchors.centerIn: parent

        glyph:"<"
        mirror:true
    }
    content:
        Item{
        anchors.fill: parent
        RowLayout {
            id: liveFeedRow

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 20
            }

            height: 300
            spacing: 20
            //Control Panel
            Dashboard_ControlPanel{
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Live Preview
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Label {
                    text: "[Live Preview]"
                    color: Theme.normal_text_theme_color
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 15
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    color: Theme.primary_theme_color
                    border.width: 1
                    border.color: Theme.border_theme_color

                    // Camera Image
                }
            }


            // Device Status
            Dashboard_DeviceStats{
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
        RowLayout{
            anchors{
                left:liveFeedRow.left
                right:liveFeedRow.right
                top:liveFeedRow.bottom
                bottom:parent.bottom
                topMargin: 20
                bottomMargin: 20
            }
            //Recent Activity
            Dashboard_RecentActivity{
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Item{
                Layout.preferredWidth: 10
            }
            //System Info
            Dashboard_SystemInfo
            {
                Layout.preferredWidth:60
                Layout.fillHeight: true
            }
        }
    }

}

