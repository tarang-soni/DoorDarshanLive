import QtQuick
import QtQuick.Controls

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Row {
        anchors.centerIn: parent
        spacing: 10 // Adds a gap between the buttons

        Button {
            width: 100
            height: 100
            text: "Start Stream"

            background: Rectangle {
                color: "black"
            }
            contentItem: Text{
                text:parent.text
                color:"white"
                horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16 // Optionally adjust font size
            }
            onClicked:{
                uiManager.requestStartStream();
            }
        }
        Button {
            width: 100
            height: 100
            text: "Stop Stream"
            background: Rectangle {
                color: "black"
            }
            contentItem: Text{
                text:parent.text
                color:"white"
                horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16 // Optionally adjust font size
            }
            onClicked:{
                uiManager.requestStopStream();
            }
        }
        Button {
            width: 100
            height: 100
            text: "quit"
            background: Rectangle {
                color: "black"
            }
            contentItem: Text{
                text:parent.text
                color:"white"
                horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16 // Optionally adjust font size
            }
            onClicked:{
                uiManager.requestQuit();
            }
        }
    }
}