import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: page

    readonly property var ui: Session.ui
    readonly property bool connected: ui ? ui.piConnected : false
    readonly property bool connecting: Session.connectingIp !== ""
    readonly property string lastIp: Session.prefs.lastPiIp
    readonly property color linkTone: connected ? Theme.success : connecting ? Theme.warning : Theme.textFaint

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        PageHeader {
            Layout.fillWidth: true
            path: "doorbell"
            title: "Doorbell"
            subtitle: "link doordarshan to the raspberry pi at your front door."
        }

        // Current link
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 132
            radius: 0
            color: Theme.surface
            border.width: 1
            border.color: page.connected ? Theme.tint(Theme.success, 0.45) : Theme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 22

                Item {
                    implicitWidth: 88
                    implicitHeight: 88
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        color: Theme.tint(page.linkTone, 0.06)
                        border.width: 1
                        border.color: Theme.tint(page.linkTone, 0.3)
                    }
                    Brackets {
                        color: page.connected ? Theme.success : Theme.borderStrong
                        length: 14
                    }
                    AppIcon {
                        anchors.centerIn: parent
                        name: "setup"
                        color: page.connected ? Theme.success : Theme.textMuted
                        size: 36
                        strokeWidth: 1.4
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Pill {
                        text: page.connected ? "Link up" : page.connecting ? "Linking" : "Link down"
                        tone: page.linkTone
                        dot: true
                        pulsing: page.connected || page.connecting
                    }
                    Text {
                        Layout.fillWidth: true
                        text: page.connected ? "DD-PI // FRONT DOOR" : page.connecting ? "REACHING DOORBELL…" : "NO DOORBELL LINKED"
                        color: Theme.text
                        font.family: Theme.fontMono
                        font.pixelSize: 20
                        font.weight: Font.Light
                        font.letterSpacing: 2
                    }
                    Text {
                        Layout.fillWidth: true
                        text: page.connected ? "NODE " + page.ui.connectedIp + (Session.streamLive ? "  ·  STREAMING " + Session.fps + " FPS" : "")
                              : page.connecting ? "NODE " + Session.connectingIp
                              : page.lastIp !== "" ? "LAST NODE " + page.lastIp
                              : "// scan your network below to find it."
                        color: Theme.textMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                }

                Row {
                    spacing: 8
                    AppButton {
                        visible: page.connected
                        text: "Reconnect"
                        iconName: "refresh"
                        onClicked: Session.reconnect()
                    }
                    AppButton {
                        visible: page.connected
                        variant: "danger"
                        text: "Disconnect"
                        iconName: "power"
                        onClicked: Session.disconnect()
                    }
                    AppButton {
                        visible: !page.connected && !page.connecting && page.lastIp !== ""
                        variant: "primary"
                        text: "Reconnect"
                        iconName: "link"
                        onClicked: Session.connectTo(page.lastIp)
                    }
                }
            }
        }

        // Discovery
        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Nearby doorbells"
            subtitle: "udp broadcast on port 40000 · this computer and the pi must share a network"

            actions: AppButton {
                variant: "primary"
                text: Session.scanning ? "Scanning…" : "Scan network"
                iconName: "wifi"
                busy: Session.scanning
                enabled: !Session.scanning
                onClicked: Session.scan()
            }

            ListView {
                id: deviceList
                anchors.fill: parent
                clip: true
                spacing: 8
                model: Session.devices
                boundsBehavior: Flickable.StopAtBounds

                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                }

                delegate: Rectangle {
                    id: device
                    required property string ip
                    required property int index
                    readonly property bool isActive: page.connected && page.ui.connectedIp === ip
                    readonly property bool isConnecting: Session.connectingIp === ip

                    width: deviceList.width
                    height: 62
                    radius: 0
                    color: isActive ? Theme.tint(Theme.success, 0.05) : Theme.surfaceSunken
                    border.width: 1
                    border.color: isActive ? Theme.tint(Theme.success, 0.5) : Theme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 16

                        Text {
                            text: Theme.pad(device.index + 1, 2)
                            color: device.isActive ? Theme.success : Theme.textFaint
                            font.family: Theme.fontMono
                            font.pixelSize: 12
                        }
                        AppIcon {
                            name: "setup"
                            color: device.isActive ? Theme.success : Theme.textMuted
                            size: 20
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: "DD-PI"
                                color: Theme.text
                                font.family: Theme.fontMono
                                font.pixelSize: 13
                                font.letterSpacing: 1.4
                            }
                            Text {
                                text: device.ip
                                color: Theme.textMuted
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                            }
                        }
                        Pill {
                            visible: device.isActive
                            text: "Linked"
                            tone: Theme.success
                            dot: true
                            pulsing: true
                        }
                        Row {
                            visible: device.isConnecting
                            spacing: 8
                            BusySpinner { anchors.verticalCenter: parent.verticalCenter; size: 14; color: Theme.warning }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "LINKING…"
                                color: Theme.warning
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                font.letterSpacing: 1.2
                            }
                        }
                        AppButton {
                            visible: !device.isActive && !device.isConnecting
                            compact: true
                            variant: "secondary"
                            text: "Connect"
                            iconName: "link"
                            onClicked: Session.connectTo(device.ip)
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                visible: deviceList.count === 0 && Session.scanning
                spacing: 18
                Radar { Layout.alignment: Qt.AlignHCenter; size: 170 }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "> broadcasting DD_DISCOVERY_"
                    color: Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                }
            }

            EmptyState {
                anchors.centerIn: parent
                visible: deviceList.count === 0 && !Session.scanning
                iconName: "wifi"
                title: "No doorbells found"
                message: "Make sure the Pi is powered on and running the DoorDarshan backend, then scan your network."
            }
        }
    }
}
