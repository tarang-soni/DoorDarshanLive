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

            StatusRow {
                label: "Pi"
                value: "Connected"
                valueColor: "#6FCF97"
            }

            StatusRow {
                label: "Camera"
                value: "Connected"
                valueColor: "#6FCF97"
            }

            StatusRow {
                label: "Stream"
                value: "Idle"
                valueColor: "#F2C94C"
            }

            StatusRow {
                label: "Motion"
                value: "Enabled"
                valueColor: "#6FCF97"
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

