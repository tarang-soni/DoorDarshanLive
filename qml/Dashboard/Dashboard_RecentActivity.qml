import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ".."

ColumnLayout {
    spacing: 8

    HeadingText {
        headingTxt: "Recent Activity"
        font.pixelSize: 15
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.primary_theme_color
        border.color: Theme.border_theme_color
        border.width: 1

        ListModel {
            id: activityModel
            ListElement { time: "11:45 AM"; log: "System connected to Pi." }
            ListElement { time: "11:50 AM"; log: "Stream started." }
            ListElement { time: "12:05 PM"; log: "Unknown visitor detected." }
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 10
            clip: true

            ListView {
                width: parent.width
                spacing: 8
                model: activityModel

                delegate: RowLayout {
                    width: ListView.view.width
                    Label {
                        text: "[" + model.time + "]"
                        color: "gray"
                        font.family: Theme.jetbrainsFont
                        font.pixelSize: 14
                    }
                    Label {
                        Layout.fillWidth: true
                        text: model.log
                        color: "white"
                        font.family: Theme.jetbrainsFont
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}