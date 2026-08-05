import QtQuick
import QtQuick.Controls

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Image {
        id: liveFeed
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
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 20
        }

        spacing: 10

        Button {
            width: 100
            height: 100
            text: "Start Stream"

            background: Rectangle {
                color: "black"
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
            }

            onClicked: uiManager.requestStartStream()
        }

        Button {
            width: 100
            height: 100
            text: "Stop Stream"

            background: Rectangle {
                color: "black"
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
            }

            onClicked: uiManager.requestStopStream()
        }

        Button {
            width: 100
            height: 100
            text: "Quit"

            background: Rectangle {
                color: "black"
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
            }

            onClicked: uiManager.requestQuit()
        }
    }
}