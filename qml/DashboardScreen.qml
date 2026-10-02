import QtQuick
import QtQuick.Layouts

Item {
    id: page

    readonly property var ui: Session.ui
    readonly property var db: Session.db
    readonly property bool connected: ui ? ui.piConnected : false

    readonly property int knownPeople: {
        Session.identitiesRevision
        return db ? db.getAllIdentities().length : 0
    }
    readonly property int visitsToday: {
        Session.historyRevision
        Session.now
        return db ? db.countVisitsToday() : 0
    }

    function greeting() {
        const hour = new Date(Session.now).getHours()
        if (hour < 5) return "good night"
        if (hour < 12) return "good morning"
        if (hour < 17) return "good afternoon"
        return "good evening"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        PageHeader {
            Layout.fillWidth: true
            path: "live"
            title: "Live view"
            subtitle: page.greeting() + ". watching your front door."

            Pill {
                text: Qt.formatDateTime(new Date(Session.now), "ddd dd MMM · hh:mm")
                tone: Theme.textMuted
            }
            Pill {
                text: page.connected ? "Link up" : "Link down"
                tone: page.connected ? Theme.success : Theme.textFaint
                dot: true
                pulsing: page.connected
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            // Left: viewport + controls
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                LiveFeedCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 300
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ControlTile {
                        Layout.fillWidth: true
                        title: "Camera"
                        iconName: checked ? "camera" : "camera-off"
                        checked: page.ui ? page.ui.cameraUiEnabled : false
                        subtitle: checked ? (Session.streamLive ? "Streaming" : "Starting…") : "Off"
                        onToggled: Session.setCamera(!checked)
                    }
                    ControlTile {
                        Layout.fillWidth: true
                        title: "Motion watch"
                        iconName: "motion"
                        checked: page.ui ? page.ui.motionEnabled : false
                        subtitle: checked ? "Armed" : "Disarmed"
                        onToggled: Session.setMotion(!checked)
                    }
                    Rectangle {
                        implicitWidth: actionsColumn.implicitWidth + 28
                        implicitHeight: 76
                        radius: 0
                        color: Theme.surface
                        border.width: 1
                        border.color: Theme.border

                        ColumnLayout {
                            id: actionsColumn
                            anchors.centerIn: parent
                            spacing: 6
                            AppButton {
                                Layout.fillWidth: true
                                compact: true
                                variant: "primary"
                                text: "Snapshot"
                                iconName: "snapshot"
                                onClicked: Session.takeSnapshot()
                            }
                            AppButton {
                                Layout.fillWidth: true
                                compact: true
                                variant: "secondary"
                                text: "Reconnect"
                                iconName: "refresh"
                                onClicked: Session.reconnect()
                            }
                        }
                    }
                }
            }

            // Right: telemetry
            ColumnLayout {
                Layout.preferredWidth: 350
                Layout.maximumWidth: 350
                Layout.fillHeight: true
                spacing: 14

                Card {
                    Layout.fillWidth: true
                    title: "System status"

                    Column {
                        width: parent.width
                        spacing: 12

                        StatusLine {
                            label: "Doorbell"
                            value: page.connected ? page.ui.connectedIp : Session.connectingIp !== "" ? "linking…" : "offline"
                            tone: page.connected ? Theme.success : Session.connectingIp !== "" ? Theme.warning : Theme.textFaint
                            pulsing: page.connected
                        }
                        StatusLine {
                            label: "Stream"
                            value: Session.streamLive ? "live · rtp/jpeg" : page.ui && page.ui.isStreaming ? "starting" : "idle"
                            tone: Session.streamLive ? Theme.live : page.ui && page.ui.isStreaming ? Theme.warning : Theme.textFaint
                            pulsing: Session.streamLive
                        }
                        StatusLine {
                            label: "Motion"
                            value: page.ui && page.ui.motionEnabled ? "armed" : "disarmed"
                            tone: page.ui && page.ui.motionEnabled ? Theme.accent : Theme.textFaint
                        }
                        StatusLine {
                            label: "At door"
                            value: Session.faceVisible ? (Session.faceKnown ? Session.faceName : "unknown visitor") : "nobody"
                            tone: Session.faceVisible ? (Session.faceKnown ? Theme.success : Theme.warning) : Theme.textFaint
                        }
                    }
                }

                Card {
                    Layout.fillWidth: true
                    title: "Video stream"

                    ColumnLayout {
                        width: parent.width
                        spacing: 10

                        RowLayout {
                            Text {
                                Layout.alignment: Qt.AlignBaseline
                                text: Session.fps
                                color: Theme.text
                                font.family: Theme.fontMono
                                font.pixelSize: 34
                                font.weight: Font.Light
                            }
                            Text {
                                Layout.alignment: Qt.AlignBaseline
                                text: "fps"
                                color: Theme.textFaint
                                font.family: Theme.fontMono
                                font.pixelSize: 12
                            }
                            Item { Layout.fillWidth: true }
                            Pill {
                                text: Session.streamLive && Session.resolution ? Session.resolution : "no signal"
                                tone: Session.streamLive ? Theme.accent : Theme.textFaint
                            }
                        }
                        FpsChart {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            samples: Session.fpsHistory
                        }
                        RowLayout {
                            Text {
                                Layout.fillWidth: true
                                text: "-60s"
                                color: Theme.textFaint
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                            }
                            Text {
                                text: "now"
                                color: Theme.textFaint
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14
                    StatTile {
                        Layout.fillWidth: true
                        label: "Visits today"
                        value: Theme.pad(page.visitsToday, 2)
                        tone: Theme.warning
                    }
                    StatTile {
                        Layout.fillWidth: true
                        label: "Known people"
                        value: Theme.pad(page.knownPeople, 2)
                        tone: Theme.success
                    }
                }

                Card {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 140
                    title: "Logs"

                    ActivityFeed {
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
