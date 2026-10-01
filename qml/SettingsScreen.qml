import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "Dashboard"

PageFrame {
    id: root

    // Tracks which tab is currently visible
    property int currentTabIndex: 0

    headerContent: HeadingText {
        font.pixelSize: 24
        headingTxt: "Settings"
        anchors.centerIn: parent
        glyph: "<"
        mirror: true
    }

    content: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            anchors.topMargin: 20
            spacing: 15

            // --- TOP TAB BAR ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: ["General", "Camera", "Network", "Alerts", "About"]

                    SidebarButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60

                        text: modelData
                        fontSize: 16
                        color: "transparent"

                        // Let your custom component handle the highlighting!
                        isSelected: root.currentTabIndex === index

                        onClicked: {
                            root.currentTabIndex = index
                        }
                    }
                }
            }

            // --- SETTINGS CONTENT AREA ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.primary_theme_color
                border.width: 1
                border.color: Theme.border_theme_color

                StackLayout {
                    anchors.fill: parent
                    anchors.margins: 1
                    currentIndex: root.currentTabIndex

                    // 0: GENERAL TAB
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 2

                            SettingToggleRow { text: "Launch on System Startup"; checked: false }
                            SettingToggleRow { text: "Auto-Delete History After 30 Days"; checked: true }

                            SettingActionRow {
                                text: "Local Database"
                                buttonText: "Clear All History"
                                onClicked: console.log("Clear History Clicked")
                            }
                        }
                    }

                    // 1: CAMERA & AI TAB
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 2

                            SettingToggleRow { text: "Enable YuNet Face Detection"; checked: true }
                            SettingToggleRow { text: "Show AI Overlays on Live Feed"; checked: true }

                            SettingSliderRow { text: "Detection Confidence Threshold"; value: 85 }
                            SettingSliderRow { text: "Linger Threshold (Frames)"; value: 15 }
                        }
                    }

                    // 2: NETWORK TAB
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 2

                            SettingToggleRow { text: "Auto-Connect to Last Known Pi"; checked: true }
                            SettingToggleRow { text: "Low Delay Option (TCP NoDelay)"; checked: true }

                            SettingActionRow {
                                text: "UDP Discovery Port"
                                buttonText: "5000"
                            }
                        }
                    }

                    // 3: ALERTS TAB
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 2

                            SettingToggleRow { text: "Enable Desktop Notifications"; checked: true }
                            SettingToggleRow { text: "Play Audio Chime on PC"; checked: false }

                            SettingSliderRow { text: "Notification Cooldown (Minutes)"; value: 1 }
                        }
                    }

                    // 4: ABOUT TAB
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 2

                            SettingTextRow { text: "Application Version"; valueText: "v1.0.0 (College Build)" }
                            SettingTextRow { text: "AI Engine"; valueText: "OpenCV 4.x + YuNet ONNX" }
                            SettingTextRow { text: "Framework"; valueText: "Qt 6 + GStreamer" }
                        }
                    }
                }
            }
        }
    }

    // --- REUSABLE INLINE COMPONENTS ---

    component SettingToggleRow: Rectangle {
        property string text: ""
        property alias checked: toggle.checked

        Layout.fillWidth: true
        Layout.preferredHeight: 80
        color: "black"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 20

            Label {
                Layout.fillWidth: true
                text: parent.parent.text
                font.family: Theme.jetbrainsFont
                font.pixelSize: 15
                color: "white"
            }
            CheckBox {
                id: toggle
            }
        }
    }

    component SettingActionRow: Rectangle {
        property string text: ""
        property string buttonText: ""
        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 80
        color: "black"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 20

            Label {
                Layout.fillWidth: true
                text: parent.parent.text
                font.family: Theme.jetbrainsFont
                font.pixelSize: 15
                color: "white"
            }
            SidebarButton {
                Layout.preferredHeight: 50
                Layout.preferredWidth: 180
                text: parent.parent.buttonText
                fontSize: 14
                onClicked: parent.parent.clicked()
            }
        }
    }

    component SettingSliderRow: Rectangle {
        property string text: ""
        property alias value: slider.value

        Layout.fillWidth: true
        Layout.preferredHeight: 80
        color: "black"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 20

            Label {
                Layout.fillWidth: true
                text: parent.parent.text + " [" + Math.round(slider.value) + "]"
                font.family: Theme.jetbrainsFont
                font.pixelSize: 15
                color: "white"
            }
            Slider {
                id: slider
                Layout.preferredWidth: 200
                from: 0
                to: 100
                stepSize: 1
            }
        }
    }

    component SettingTextRow: Rectangle {
        property string text: ""
        property string valueText: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 80
        color: "black"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 20

            Label {
                Layout.fillWidth: true
                text: parent.parent.text
                font.family: Theme.jetbrainsFont
                font.pixelSize: 15
                color: "white"
            }
            Label {
                text: parent.parent.valueText
                font.family: Theme.jetbrainsFont
                font.pixelSize: 15
                color: "gray"
            }
        }
    }
}