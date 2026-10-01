import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: controlPanelRoot
    spacing: 8

    // Expose these properties so DashboardScreen can read them
    property bool isCameraUiOn: app && app.uiManager ? app.uiManager.isStreaming : false
    property bool isMotionOn: false

    // Listens to the background stream to update instantly
    Connections {
        target: app ? app.videoBridge : null

        function onStreamStopped() {
            // If the stream dies (e.g. network drop), reset both UI toggles
            controlPanelRoot.isCameraUiOn = false;
            controlPanelRoot.isMotionOn = false;
        }
    }

    HeadingText {
        headingTxt: "Control Panel"
        font.pixelSize: 15
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.primary_theme_color
        border.width: 1
        border.color: Theme.border_theme_color

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            SidebarButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "Refresh"
                fontSize: 15
                color: "transparent"
            }

            // --- CAMERA TOGGLE ---
            SidebarButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            text: (app && app.uiManager.cameraUiEnabled) ? "Camera : ON" : "Camera : OFF"
                            fontSize: 15
                            color: "transparent"
                            onClicked: {
                                if (app) {
                                    // Just flip the state! C++ evaluateStreamState() handles the rest.
                                    app.uiManager.cameraUiEnabled = !app.uiManager.cameraUiEnabled;
                                }
                            }
                        }

            // --- MOTION TOGGLE ---
            SidebarButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            text: (app && app.uiManager.motionEnabled) ? "Motion : ON" : "Motion : OFF"
                            fontSize: 15
                            color: "transparent"
                            onClicked: {
                                if (app) {
                                    // Just flip the state! C++ evaluateStreamState() handles the rest.
                                    app.uiManager.motionEnabled = !app.uiManager.motionEnabled;
                                }
                            }
                        }

            SidebarButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "Snapshot"
                fontSize: 15
                color: "transparent"
                onClicked: {
                    if (app) {
                        app.takeManualSnapshot();
                    }
                }
            }

            SidebarButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "Reconnect"
                fontSize: 15
                color: "transparent"
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}