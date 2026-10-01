import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"

PageFrame {
    id: root

    headerContent: HeadingText {
        font.pixelSize: 24
        headingTxt: "Saved Visitors"
        anchors.centerIn: parent
        glyph: "<"
        mirror: true
    }

    ListModel {
        id: identitiesModel
        ListElement { personName: "Ramesh"; dateAdded: "Enrolled: Aug 15, 2026"; imagePath: "" }
        ListElement { personName: "Suresh"; dateAdded: "Enrolled: Sep 02, 2026"; imagePath: "" }
    }

    content: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            anchors.topMargin: 20
            spacing: 15

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    Layout.fillWidth: true
                    text: "Enrolled Identities (" + identitiesModel.count + ")"
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 18
                    color: "white"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.primary_theme_color
                border.width: 1
                border.color: Theme.border_theme_color

                Label {
                    anchors.centerIn: parent
                    text: "No saved visitors. Save faces from the History tab."
                    color: "gray"
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 16
                    visible: identitiesModel.count === 0
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true

                    ListView {
                        width: parent.width
                        spacing: 2
                        model: identitiesModel

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 100
                            color: "black"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 20

                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 80
                                    color: "#1A1A1A"
                                    border.color: Theme.border_theme_color
                                    border.width: 1

                                    Label {
                                        anchors.centerIn: parent
                                        text: "IMG"
                                        color: "gray"
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 12
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.personName
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#00FF00"
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.dateAdded
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 14
                                        color: "gray"
                                    }
                                }

                                SidebarButton {
                                    Layout.preferredHeight: 40
                                    Layout.preferredWidth: 100
                                    text: "Edit"
                                    fontSize: 14
                                    color: "transparent"
                                    onClicked: {
                                        console.log("Edit clicked for: " + model.personName)
                                    }
                                }

                                SidebarButton {
                                    Layout.preferredHeight: 40
                                    Layout.preferredWidth: 100
                                    Layout.rightMargin: 10
                                    text: "Delete"
                                    fontSize: 14
                                    color: "transparent"
                                    onClicked: {
                                        identitiesModel.remove(index);
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