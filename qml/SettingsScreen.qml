import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: page

    readonly property var db: Session.db
    readonly property int historyCount: {
        Session.historyRevision
        return db ? db.getHistoryLogs().length : 0
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        PageHeader {
            Layout.fillWidth: true
            path: "settings"
            title: "Settings"
            subtitle: "choose how doordarshan watches your door and lets you know."
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            RowLayout {
                width: parent.width
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 14

                    Card {
                        Layout.fillWidth: true
                        title: "Live view"
                        iconName: "camera"

                        Column {
                            width: parent.width
                            SettingRow {
                                iconName: "eye"
                                title: "Show face boxes"
                                description: "Outline faces on the live feed and label people you've named."
                                divider: false
                                ToggleSwitch {
                                    checked: Session.prefs.showFaceOverlay
                                    onToggled: Session.prefs.showFaceOverlay = checked
                                }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        title: "Visitor alerts"
                        subtitle: "fire when motion watch sees a face for ~1 second (30 frames)"
                        iconName: "bell"

                        Column {
                            width: parent.width
                            SettingRow {
                                iconName: "bell"
                                title: "Desktop notifications"
                                description: "Show a system notification when someone is at the door."
                                ToggleSwitch {
                                    checked: Session.prefs.desktopNotifications
                                    onToggled: Session.prefs.desktopNotifications = checked
                                }
                            }
                            SettingRow {
                                iconName: "dashboard"
                                title: "Bring DoorDarshan to the front"
                                description: "Open the live view and turn on the camera so you can see who it is."
                                divider: false
                                ToggleSwitch {
                                    checked: Session.prefs.raiseOnAlert
                                    onToggled: Session.prefs.raiseOnAlert = checked
                                }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        title: "Your data"
                        subtitle: "snapshots and face encodings stay on this computer"
                        iconName: "database"

                        Column {
                            width: parent.width
                            SettingRow {
                                iconName: "history"
                                title: "Visitor history"
                                description: page.historyCount + (page.historyCount === 1 ? " snapshot" : " snapshots") + " saved"
                                divider: false
                                AppButton {
                                    variant: "danger"
                                    text: "Clear history"
                                    enabled: page.historyCount > 0
                                    onClicked: clearDialog.open()
                                }
                            }
                        }
                    }
                }

                Card {
                    Layout.preferredWidth: 400
                    Layout.alignment: Qt.AlignTop
                    title: "About"
                    iconName: "info"

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        RowLayout {
                            Layout.bottomMargin: 18
                            spacing: 14
                            Item {
                                implicitWidth: 52
                                implicitHeight: 52
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    color: Theme.tint(Theme.accent, 0.08)
                                    border.width: 1
                                    border.color: Theme.tint(Theme.accent, 0.35)
                                }
                                Brackets { color: Theme.accent; length: 9 }
                                AppIcon {
                                    anchors.centerIn: parent
                                    name: "eye"
                                    color: Theme.accent
                                    size: 22
                                    strokeWidth: 2
                                }
                            }
                            ColumnLayout {
                                spacing: 0
                                Text {
                                    text: "DOORDARSHAN LIVE"
                                    color: Theme.text
                                    font.family: Theme.fontMono
                                    font.pixelSize: 15
                                    font.letterSpacing: 2
                                }
                                Text {
                                    text: "Version " + Qt.application.version
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Repeater {
                            model: [
                                { k: "Face recognition", v: "OpenCV YuNet + SFace" },
                                { k: "Video", v: "RTP/JPEG · UDP 5000" },
                                { k: "Discovery", v: "UDP broadcast · 40000" },
                                { k: "Control", v: "TCP · ephemeral port" },
                                { k: "Built with", v: "Qt 6 · GStreamer" }
                            ]
                            RowLayout {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                spacing: 8
                                Text {
                                    Layout.preferredWidth: 130
                                    text: modelData.k
                                    color: Theme.textMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.letterSpacing: 1
                                    font.capitalization: Font.AllUppercase
                                }
                                Text {
                                    text: ":"
                                    color: Theme.textFaint
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.v
                                    color: Theme.text
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    AppDialog {
        id: clearDialog
        title: "Clear all history?"
        message: "This removes all " + page.historyCount + " snapshots from History. People you've already named stay saved."
        iconName: "trash"
        tone: Theme.danger
        destructive: true
        confirmText: "Clear history"
        onConfirmed: {
            page.db.clearHistory()
            Session.historyRevision++
            Session.notify("History cleared", "success")
        }
    }
}
