import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"

PageFrame {
    id: root

    headerContent: HeadingText {
        font.pixelSize: 24
        headingTxt: "History Log"
        anchors.centerIn: parent
        glyph: "<"
        mirror: true
    }

    ListModel {
        id: historyModel
    }

    function loadHistory() {
        historyModel.clear();
        if (app && app.databaseManager) {
            var logs = app.databaseManager.getHistoryLogs();
            for (var i = 0; i < logs.length; i++) {
                historyModel.append(logs[i]);
            }
        }
    }

    Component.onCompleted: {
        loadHistory();
    }

    content: Item {
        anchors.fill: parent

        // --- THE SAVE FACE DIALOG POPUP ---
        Popup {
            id: saveFaceDialog
            width: 450
            height: 250
            anchors.centerIn: parent
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Properties to hold the data of the row we clicked
            property int targetHistoryId: -1
            property string targetImagePath: ""

            background: Rectangle {
                color: Theme.primary_theme_color
                border.color: Theme.border_theme_color
                border.width: 1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                Label {
                    Layout.fillWidth: true
                    text: "Identify Visitor"
                    color: "white"
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 20
                    font.bold: true
                }

                TextField {
                    id: nameInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    placeholderText: "e.g., Rahul, Swiggy Delivery..."
                    color: "white"
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 16

                    background: Rectangle {
                        color: "black"
                        // Glows white instead of green to match your minimal theme
                        border.color: nameInput.activeFocus ? "white" : Theme.border_theme_color
                        border.width: 1
                    }
                }

                Item { Layout.fillHeight: true } // Pushes buttons to the bottom

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    SidebarButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        text: "Cancel"
                        fontSize: 14
                        color: "transparent"
                        onClicked: {
                            saveFaceDialog.close()
                            nameInput.text = ""
                        }
                    }

                    SidebarButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        text: "Save Identity"
                        fontSize: 14
                        color: "transparent"
                        onClicked: {
                            if (nameInput.text.trim() !== "") {
                                if (app && app.databaseManager) {
                                    var success = app.databaseManager.nameUnknownVisitor(saveFaceDialog.targetHistoryId, nameInput.text.trim());
                                    if (success) {
                                        loadHistory();
                                        app.reloadAIIdentities();
                                    }
                                }
                                saveFaceDialog.close();
                                nameInput.text = "";
                            }
                        }
                    }
                }
            }
        }

        // --- MAIN PAGE LAYOUT ---
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
                    text: "Recent Snapshots (" + historyModel.count + ")"
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 18
                    color: "white"
                }

                SidebarButton {
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 160
                    text: "Clear History"
                    fontSize: 14
                    color: "transparent"
                    onClicked: {
                        if (app && app.databaseManager) {
                            app.databaseManager.clearHistory();
                            loadHistory();
                        }
                    }
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
                    text: "No history logs found."
                    color: "gray"
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 16
                    visible: historyModel.count === 0
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true

                    ListView {
                        width: parent.width
                        spacing: 2
                        model: historyModel

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 100
                            color: "black"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 20

                                // Image Thumbnail
                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 80
                                    color: "#1A1A1A"
                                    border.color: Theme.border_theme_color
                                    border.width: 1

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: model.imagePath ? "file:///" + model.imagePath : ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true

                                        Label {
                                            anchors.centerIn: parent
                                            text: "IMG"
                                            color: "gray"
                                            font.family: Theme.jetbrainsFont
                                            font.pixelSize: 12
                                            visible: parent.status === Image.Error || parent.status === Image.Null
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.visitorName
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: model.isKnown ? "#00FF00" : "white"
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.timestamp
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 14
                                        color: "gray"
                                    }
                                }

                                // KNOWN/UNKNOWN Badge
                                Rectangle {
                                    Layout.preferredWidth: 90
                                    Layout.preferredHeight: 30
                                    color: "transparent"
                                    border.color: Theme.border_theme_color
                                    radius: 4

                                    Label {
                                        anchors.centerIn: parent
                                        text: model.isKnown ? "KNOWN" : "UNKNOWN"
                                        color: model.isKnown ? "#00FF00" : "#FF4444"
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }

                                SidebarButton {
                                    visible: !model.isKnown
                                    Layout.preferredHeight: 40
                                    Layout.preferredWidth: 120
                                    Layout.leftMargin: 10
                                    text: "Save Face"
                                    fontSize: 14
                                    color: "transparent"
                                    onClicked: {
                                        saveFaceDialog.targetHistoryId = model.id;
                                        saveFaceDialog.targetImagePath = model.imagePath;
                                        saveFaceDialog.open();
                                    }
                                }

                                SidebarButton {
                                    Layout.preferredHeight: 40
                                    Layout.preferredWidth: 100
                                    Layout.leftMargin: 10
                                    Layout.rightMargin: 10
                                    text: "Delete"
                                    fontSize: 14
                                    color: "transparent"
                                    onClicked: {
                                        // Removes it locally from UI for now
                                        historyModel.remove(index);
                                        // Optional: You can add app.databaseManager.deleteHistoryLog(model.id) later
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