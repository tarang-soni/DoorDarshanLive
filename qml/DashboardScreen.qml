import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt.labs.platform
import "Dashboard"

PageFrame {
    id: root
    headerContent: HeadingText {
        font.pixelSize: 24
        headingTxt: "Dashboard"
        anchors.centerIn: parent
        glyph: "<"
        mirror: true
    }

    content: Item {
        anchors.fill: parent

        RowLayout {
            id: liveFeedRow
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 20
            }
            height: 300
            spacing: 20

            // ADDED ID: controlPanel so we can read its properties
            Dashboard_ControlPanel {
                id: controlPanel
                Layout.preferredWidth: 60
                Layout.fillHeight: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                HeadingText {
                    headingTxt: "Live Preview"
                    font.pixelSize: 15
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.primary_theme_color
                    border.width: 1
                    border.color: Theme.border_theme_color

                        Image {
                        id: liveFeed
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        source: "image://camera/live"

                        // NEW: Hide video completely if Camera is toggled OFF
                        visible: app ? app.uiManager.cameraUiEnabled : false

                        // Custom properties to store the raw C++ coordinates
                        property int rawFaceX: 0
                        property int rawFaceY: 0
                        property int rawFaceW: 0
                        property int rawFaceH: 0
                        property string faceName: ""
                        property bool faceVisible: false

                        // The dynamic Bounding Box
                        Rectangle {
                            id: faceBox
                            visible: liveFeed.faceVisible
                            color: "transparent"
                            border.color: (liveFeed.faceName !== "" && liveFeed.faceName !== "Unknown") ? "#00FF00" : "#FFB800"
                            border.width: 3

                            property real scaleX: liveFeed.paintedWidth / (liveFeed.sourceSize.width || 640)
                            property real scaleY: liveFeed.paintedHeight / (liveFeed.sourceSize.height || 480)
                            property real offsetX: (liveFeed.width - liveFeed.paintedWidth) / 2
                            property real offsetY: (liveFeed.height - liveFeed.paintedHeight) / 2

                            x: (liveFeed.rawFaceX * scaleX) + offsetX
                            y: (liveFeed.rawFaceY * scaleY) + offsetY
                            width: liveFeed.rawFaceW * scaleX
                            height: liveFeed.rawFaceH * scaleY

                            // The Name Label attached to the top of the box
                            Rectangle {
                                anchors.bottom: parent.top
                                anchors.left: parent.left
                                width: parent.width
                                height: 26
                                color: (liveFeed.faceName !== "" && liveFeed.faceName !== "Unknown") ? "#00FF00" : "#FFB800"

                                Label {
                                    anchors.centerIn: parent
                                    text: liveFeed.faceName
                                    color: "black"
                                    font.family: Theme.jetbrainsFont
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                Connections {
                    target: app ? app.videoBridge : null

                    function onFrameReady() {
                        // Only pull image updates if the video is visible to save CPU!
                        if (liveFeed.visible) {
                            liveFeed.source = ""
                            liveFeed.source = "image://camera/live?" + Date.now()
                        }
                    }

                    function onStreamStopped() {
                        liveFeed.source = ""
                        liveFeed.faceVisible = false
                    }

                    function onFaceDetected(faceX, faceY, faceW, faceH, faceName) {
                        // Only draw the green box if video is visible
                        if (liveFeed.visible) {
                            liveFeed.rawFaceX = faceX
                            liveFeed.rawFaceY = faceY
                            liveFeed.rawFaceW = faceW
                            liveFeed.rawFaceH = faceH
                            liveFeed.faceName = faceName
                            liveFeed.faceVisible = true
                        }
                    }

                    function onFaceLost() {
                        liveFeed.faceVisible = false
                    }
                    function onMotionAlertTriggered() {
                        console.log("System Alert: Motion & Face threshold met!");
                        if (app) {
                            app.takeManualSnapshot();

                            var name = liveFeed.faceName;
                            var visitorStr = (name !== "" && name !== "Unknown") ? name : "An Unknown Visitor";

                            appTrayIcon.showMessage("DoorDarshan Alert \uD83D\uDD14",
                                                    visitorStr + " is lingering at the door.",
                                                    SystemTrayIcon.Information,
                                                    5000);

                            // NEW: Automatically maximize the app right to the screen!
                            mainWindow.forceRestoreWindow();
                        }
                    }
                }
            }

            Dashboard_DeviceStats {
                Layout.preferredWidth: 240
                Layout.fillHeight: true
            }
        }

        RowLayout {
            anchors {
                left: liveFeedRow.left
                right: liveFeedRow.right
                top: liveFeedRow.bottom
                bottom: parent.bottom
                topMargin: 20
                bottomMargin: 20
            }
            spacing: 20

            Dashboard_RecentActivity {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Dashboard_SystemInfo {
                Layout.preferredWidth: 240
                Layout.fillHeight: true
            }
        }
    }
}