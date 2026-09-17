import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"
PageFrame{
    id: root
    headerContent:HeadingText{
        font.pixelSize:24
        headingTxt:"Dashboard"
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

                HeadingText {
                    headingTxt: "Live Preview"
                    font.pixelSize: 15
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    color: Theme.primary_theme_color
                    border.width: 1
                    border.color: Theme.border_theme_color

                    //Camera Image
                    Image {
                        id: liveFeed
                        //anchors.centerIn: parent
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        source: "image://camera/live"
                    }

                    Connections {
                        target: videoBridge

                        function onFrameReady() {
                            liveFeed.source = ""
                            liveFeed.source = "image://camera/live?" + Date.now()
                        }
                        function onStreamStopped() {
                                liveFeed.source = ""
                            }
                    }
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
// Image {
//     id: liveFeed
//     anchors.centerIn: parent
//     anchors.fill: parent*.5
//     fillMode: Image.PreserveAspectFit
//     cache: false
//     source: "image://camera/live"
// }

// Connections {
//     target: videoBridge

//     function onFrameReady() {
//         liveFeed.source = ""
//         liveFeed.source = "image://camera/live?" + Date.now()
//     }
// }

// Row {
//     anchors {
//         horizontalCenter: parent.horizontalCenter
//         bottom: parent.bottom
//         bottomMargin: 20
//     }

//     spacing: 10

//     Button {
//         width: 100
//         height: 100
//         text: "Start Stream"

//         background: Rectangle {
//             color: "black"
//         }

//         contentItem: Text {
//             text: parent.text
//             color: "white"
//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter
//             font.pixelSize: 16
//         }

//         onClicked: uiManager.requestStartStream()
//     }

//     Button {
//         width: 100
//         height: 100
//         text: "Stop Stream"

//         background: Rectangle {
//             color: "black"
//         }

//         contentItem: Text {
//             text: parent.text
//             color: "white"
//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter
//             font.pixelSize: 16
//         }

//         onClicked: uiManager.requestStopStream()
//     }

//     Button {
//         width: 100
//         height: 100
//         text: "Quit"

//         background: Rectangle {
//             color: "black"
//         }

//         contentItem: Text {
//             text: parent.text
//             color: "white"
//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter
//             font.pixelSize: 16
//         }

//         onClicked: uiManager.requestQuit()
//     }
// }
