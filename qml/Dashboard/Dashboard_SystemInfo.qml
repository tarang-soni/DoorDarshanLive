import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ".."
ColumnLayout {

    spacing: 8

    HeadingText {
        headingTxt: "System Information"
        font.pixelSize: 15
    }
    Rectangle{

        Layout.fillWidth: true
        Layout.fillHeight: true

        color:Theme.primary_theme_color
        border.color:Theme.border_theme_color
        border.width:1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            StatusRow {
                label: "CPU Usage"
                value: "12%"
                valueColor: "#6FCF97"
                textSpacing: 100
            }

            StatusRow {
                label: "Memory"
                value: "180 MB"
                valueColor: "#6FCF97"
                textSpacing: 100
            }

            StatusRow {
                label: "Disk"
                value: "22 GB Free"
                valueColor: "#F2C94C"
                textSpacing: 100
            }

            StatusRow {
                label: "FPS"
                value: "30"
                valueColor: "#6FCF97"
                textSpacing: 100
            }
            StatusRow {
                label: "Resolution"
                value: "640x480"
                valueColor: "#6FCF97"
                textSpacing: 100
            }
            StatusRow {
                label: "Network"
                value: "18 Mbps"
                valueColor: "#6FCF97"
                textSpacing: 100
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
