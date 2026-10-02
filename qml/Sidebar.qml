import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string currentPage: "dashboard"
    signal navigate(string page)

    readonly property var ui: Session.ui
    readonly property bool connected: ui ? ui.piConnected : false
    readonly property bool connecting: Session.connectingIp !== ""

    implicitWidth: 248
    color: Theme.sidebar

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.border
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        anchors.topMargin: 22
        spacing: 2

        // Brand
        RowLayout {
            Layout.bottomMargin: 30
            spacing: 12

            Item {
                implicitWidth: 38
                implicitHeight: 38
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    color: Theme.tint(Theme.accent, 0.08)
                    border.width: 1
                    border.color: Theme.tint(Theme.accent, 0.35)
                }
                Brackets { color: Theme.accent; length: 7 }
                AppIcon {
                    anchors.centerIn: parent
                    name: "eye"
                    color: Theme.accent
                    size: 18
                    strokeWidth: 2
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: "DOORDARSHAN"
                    color: Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    font.letterSpacing: 2.4
                }
                Text {
                    text: "SMART DOORBELL // v" + Qt.application.version
                    color: Theme.textFaint
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                    font.letterSpacing: 1.2
                }
            }
        }

        Text {
            Layout.bottomMargin: 8
            text: "// NAVIGATION"
            color: Theme.textFaint
            font.family: Theme.fontMono
            font.pixelSize: 10
            font.letterSpacing: 1.6
        }

        Repeater {
            model: [
                { page: "dashboard", label: "Live view", icon: "dashboard" },
                { page: "history", label: "History", icon: "history" },
                { page: "people", label: "People", icon: "users" },
                { page: "setup", label: "Doorbell", icon: "setup" },
                { page: "settings", label: "Settings", icon: "settings" }
            ]
            NavItem {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                number: index + 1
                label: modelData.label
                iconName: modelData.icon
                selected: root.currentPage === modelData.page
                onClicked: root.navigate(modelData.page)
            }
        }

        Item { Layout.fillHeight: true }

        // Link status panel
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: statusColumn.implicitHeight + 26
            radius: 0
            color: Theme.surface
            border.width: 1
            border.color: root.connected ? Theme.tint(Theme.accent, 0.35) : Theme.border
            Behavior on border.color { ColorAnimation { duration: Theme.durationNormal } }

            ColumnLayout {
                id: statusColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 13
                spacing: 10

                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "LINK STATUS"
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.letterSpacing: Theme.labelSpacing
                    }
                    Pill {
                        text: root.connected ? "Online" : root.connecting ? "Linking" : "Offline"
                        tone: root.connected ? Theme.success : root.connecting ? Theme.warning : Theme.textFaint
                        dot: true
                        pulsing: root.connected || root.connecting
                    }
                }

                Text {
                    text: root.connected ? root.ui.connectedIp
                          : root.connecting ? Session.connectingIp
                          : "--.--.--.--"
                    color: root.connected ? Theme.text : Theme.textFaint
                    font.family: Theme.fontMono
                    font.pixelSize: 13
                }

                ColumnLayout {
                    visible: Session.streamLive
                    Layout.fillWidth: true
                    spacing: 6
                    RowLayout {
                        Text {
                            Layout.fillWidth: true
                            text: "● STREAM"
                            color: Theme.live
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            font.letterSpacing: 1.2
                        }
                        Text {
                            text: Session.fps + " FPS"
                            color: Theme.textMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                        }
                    }
                    SegmentMeter {
                        value: Session.fps / 30
                        segments: 24
                        segmentWidth: 6
                        segmentHeight: 8
                        spacing: 2
                    }
                }

                AppButton {
                    visible: !root.connected
                    Layout.fillWidth: true
                    compact: true
                    variant: "secondary"
                    text: root.connecting ? "View" : "Connect"
                    iconName: "arrow-right"
                    onClicked: root.navigate("setup")
                }
            }
        }
    }
}
