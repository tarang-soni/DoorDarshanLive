import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ".."
ColumnLayout {

    spacing: 8

    HeadingText {
        headingTxt: "Device Status"
        font.pixelSize: 15
    }

    Rectangle {
        Layout.preferredWidth:240
        Layout.fillHeight: true

        color: Theme.primary_theme_color
        border.width: 1
        border.color: Theme.border_theme_color

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            BoolStatusRow {
                label: "Pi"
                isOn:uiManager.piConnected
            }

            BoolStatusRow {
                label: "Camera"
                isOn:false
            }

            BoolStatusRow {
                id:streamStatus
                label: "Stream"
                falseValue: "Idle"
                falseColor: Theme.status_yellow
                isOn:false
            }

            BoolStatusRow {
                label: "Motion"
                trueValue: "Enabled"
                falseValue:"Disabled"
                isOn:false
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
    Connections {
        target: videoBridge
        function onFrameReady() {
            streamStatus.isOn=true
        }
        function onStreamStopped() {
                streamStatus.isOn=false
            }
    }
}

