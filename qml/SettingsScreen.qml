import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"
PageFrame{
    id: root
    headerContent:HeadingText{
        font.pixelSize:24
        headingTxt:"Settings"
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
            spacing:20
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: ["General", "Camera", "Network", "Alerts", "About"]

                    SidebarButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60

                        text: modelData
                        fontSize: 16
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: Theme.primary_theme_color
                border.width: 1
                border.color: Theme.border_theme_color
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
