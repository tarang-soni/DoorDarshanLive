import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"
PageFrame{
    id: root
    headerContent:HeadingText{
        font.pixelSize:24
        headingTxt:"Device Setup"
        anchors.centerIn: parent

        glyph:"<"
        mirror:true
    }
    content:
        Item{
        anchors.fill: parent
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 40
            anchors.topMargin:20
            spacing:10
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SidebarButton {
                    Layout.preferredHeight: 60

                    text: "Find Pi"
                    fontSize: 16
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: Theme.primary_theme_color
                border.width: 1
                border.color: Theme.border_theme_color
                ScrollView{
                    anchors.fill: parent
                    anchors.margins: 1
                    ColumnLayout{
                        width:parent.width
                        spacing:1
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color:"black"
                            RowLayout{
                                anchors.fill:parent
                                spacing:20
                                ColumnLayout{
                                    Layout.fillWidth: true
                                    Label{
                                        Layout.leftMargin: 20
                                        Layout.fillWidth: true
                                        text:"DoorDarshan Pi"
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 15
                                        color:"white"
                                    }
                                    Label{
                                        Layout.leftMargin: 20
                                        Layout.fillWidth: true
                                        text:"IP: 192.168.1.1"
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 15
                                        color:"white"
                                    }
                                    Label{
                                        Layout.leftMargin: 20
                                        Layout.fillWidth: true
                                        text:"Serial-ID: ABCD-EFG"
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 15
                                        color:"white"
                                    }
                                }
                                SidebarButton {
                                    Layout.preferredHeight: 60

                                    text: "Connect"
                                    fontSize: 16
                                    color:"transparent"
                                }


                            }


                        }
                    }
                }
            }
        }
    }

}