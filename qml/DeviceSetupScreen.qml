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
    ListModel{
        id: discoveredDevicesModel
    }

    Connections{
        target: app.uiManager
        function onDeviceFound(ip)
        {
            console.log("Adding IP to UI: " + ip)
            discoveredDevicesModel.append({"ipAddress":ip})
        }
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
                    onClicked: {
                        discoveredDevicesModel.clear();
                        app.uiManager.findDevices();
                    }
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
                    ListView{
                        id:deviceListView
                        width:parent.width
                        spacing:1
                        model:discoveredDevicesModel
                        delegate: Rectangle{
                            width: ListView.view.width
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
                                        text:"IP:" +model.ipAddress
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 15
                                        color:"white"
                                    }

                                }
                                Item{
                                    Layout.fillWidth: true
                                }

                                SidebarButton {
                                    Layout.preferredHeight: 60
                                    Layout.rightMargin: 20
                                    text: "Connect"
                                    fontSize: 16
                                    color:"transparent"
                                    onClicked: {
                                        app.uiManager.connectToPi(model.ipAddress);
                                    }

                                }


                            }


                        }

                    }
                }
            }
        }
    }

}