import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"

PageFrame {
    id: root

    // State tracker for scanning text
    property bool isScanning: false

    headerContent: HeadingText {
        font.pixelSize: 24
        headingTxt: "Device Setup"
        anchors.centerIn: parent
        glyph: "<"
        mirror: true
    }

    ListModel {
        id: discoveredDevicesModel
    }

    Connections {
        target: app.uiManager
        function onDeviceFound(ip) {
            // Check for duplicates before adding
            let exists = false;
            for (let i = 0; i < discoveredDevicesModel.count; ++i) {
                if (discoveredDevicesModel.get(i).ipAddress === ip) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                discoveredDevicesModel.append({"ipAddress": ip})
            }
            isScanning = false
        }
        function onDeviceDiscoveryStopped() {
            isScanning = false
        }
    }

    content: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            anchors.topMargin: 20
            spacing: 15

            // --- ALWAYS VISIBLE: Status Panel ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "black"
                border.width: 1
                border.color: app.uiManager.piConnected ? "#00FF00" : Theme.border_theme_color

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    ColumnLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.leftMargin: 20
                            Layout.fillWidth: true
                            text: app.uiManager.piConnected ? "Active Device: DoorDarshan Pi" : "No Device Connected"
                            font.family: Theme.jetbrainsFont
                            font.pixelSize: 16
                            font.bold: true
                            color: app.uiManager.piConnected ? "white" : "gray"
                        }
                        Label {
                            Layout.leftMargin: 20
                            Layout.fillWidth: true
                            text: app.uiManager.piConnected ? "IP: " + app.uiManager.connectedIp : "IP: --.---.-.-"
                            font.family: Theme.jetbrainsFont
                            font.pixelSize: 14
                            color: app.uiManager.piConnected ? "#00FF00" : "gray"
                        }
                    }

                    // INTERACTIVE DISCONNECT BUTTON
                    Label {
                        text: app.uiManager.piConnected ? "[ DISCONNECT ]" : "[ DISCONNECTED ]"
                        color: app.uiManager.piConnected ? "#ff5555" : "gray" // Red when connected to indicate disconnect action
                        font.family: Theme.jetbrainsFont
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 20

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: app.uiManager.piConnected
                            onClicked: {
                                app.uiManager.disconnectPi();
                            }
                        }
                    }
                }
            }
            // ---------------------------------------------------------------

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SidebarButton {
                    Layout.preferredHeight: 60
                    text: "Find Pi"
                    fontSize: 16
                    onClicked: {
                        discoveredDevicesModel.clear();

                        // If we are already connected to a Pi, put it back in the list immediately
                        if (app.uiManager.piConnected && app.uiManager.connectedIp !== "") {
                            discoveredDevicesModel.append({"ipAddress": app.uiManager.connectedIp});
                        }

                        root.isScanning = true;
                        app.uiManager.findDevices();
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.primary_theme_color
                border.width: 1
                border.color: Theme.border_theme_color

                // Overlay text for Scanning / Empty State
                Label {
                    anchors.centerIn: parent
                    text: root.isScanning ? "Scanning network for Pi..." : "No devices found. Click 'Find Pi'."
                    color: "gray"
                    font.family: Theme.jetbrainsFont
                    font.pixelSize: 16
                    visible: discoveredDevicesModel.count === 0
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 1

                    ListView {
                        id: deviceListView
                        width: parent.width
                        spacing: 1
                        model: discoveredDevicesModel

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 80
                            color: "black"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 20

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        Layout.leftMargin: 20
                                        Layout.fillWidth: true
                                        text: "DoorDarshan Pi"
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 15
                                        color: "white"
                                    }
                                    Label {
                                        Layout.leftMargin: 20
                                        Layout.fillWidth: true
                                        text: "IP: " + ipAddress
                                        font.family: Theme.jetbrainsFont
                                        font.pixelSize: 15
                                        color: "gray"
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                // Shows a green label inside the list for the specific connected Pi
                                Label {
                                    visible: app.uiManager.piConnected && ipAddress === app.uiManager.connectedIp
                                    text: "Connected"
                                    color: "#00FF00"
                                    font.family: Theme.jetbrainsFont
                                    font.pixelSize: 16
                                    font.bold: true
                                    Layout.rightMargin: 30
                                }

                                // Connect button stays visible for any Pi that is NOT the active one
                                SidebarButton {
                                    visible: ipAddress !== app.uiManager.connectedIp
                                    Layout.preferredHeight: 50
                                    Layout.preferredWidth: 120
                                    Layout.rightMargin: 20
                                    text: "Connect"
                                    fontSize: 16
                                    color: "transparent"
                                    onClicked: {
                                        if (app.uiManager.piConnected) {
                                            app.uiManager.disconnectPi();
                                        }
                                        app.uiManager.connectToPi(ipAddress);
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