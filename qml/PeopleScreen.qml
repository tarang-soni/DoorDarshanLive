import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: page

    readonly property var db: Session.db

    ListModel { id: peopleModel }

    function reload() {
        peopleModel.clear()
        const people = db ? db.getAllIdentities() : []
        for (let i = 0; i < people.length; ++i)
            peopleModel.append(people[i])
    }

    Component.onCompleted: reload()

    Connections {
        target: Session
        function onIdentitiesRevisionChanged() { page.reload() }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        PageHeader {
            Layout.fillWidth: true
            path: "people"
            title: "People"
            subtitle: peopleModel.count === 0 ? "faces doordarshan recognises."
                                             : peopleModel.count + (peopleModel.count === 1 ? " identity" : " identities") + " enrolled for recognition"

            AppButton {
                variant: "secondary"
                text: "Name a visitor"
                iconName: "user-plus"
                onClicked: Session.navigate("history")
            }
        }

        // How recognition works
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: tip.implicitHeight + 24
            radius: 0
            color: Theme.tint(Theme.accent, 0.04)
            border.width: 1
            border.color: Theme.tint(Theme.accent, 0.3)

            RowLayout {
                id: tip
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12
                Text {
                    text: "> TIP"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: "Name an unknown visitor in History and DoorDarshan learns their face on the spot. They are labelled on the live view from then on."
                    color: Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: grid
                anchors.fill: parent
                anchors.margins: -7
                clip: true
                model: peopleModel
                boundsBehavior: Flickable.StopAtBounds
                readonly property int columns: Math.max(1, Math.floor(width / 240))
                cellWidth: Math.floor(width / columns)
                cellHeight: 240
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Item {
                    id: cell
                    width: grid.cellWidth
                    height: grid.cellHeight
                    readonly property int personId: model.id
                    readonly property string personName: model.personName

                    Card {
                        anchors.fill: parent
                        anchors.margins: 7
                        padding: 14
                        hoverable: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "ID-" + Theme.pad(cell.personId, 3)
                                    color: Theme.textFaint
                                    font.family: Theme.fontMono
                                    font.pixelSize: 10
                                    font.letterSpacing: 1
                                }
                                AppButton {
                                    compact: true
                                    variant: "ghost"
                                    iconName: "trash"
                                    implicitHeight: 24
                                    onClicked: {
                                        removeDialog.targetId = cell.personId
                                        removeDialog.targetName = cell.personName
                                        removeDialog.open()
                                    }
                                }
                            }
                            Avatar {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 4
                                size: 92
                                name: model.personName
                                source: model.imagePath
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 14
                                Layout.maximumWidth: cell.width - 50
                                text: model.personName
                                color: Theme.text
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                                font.letterSpacing: 1
                                font.capitalization: Font.AllUppercase
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 3
                                text: "ENROLLED " + (model.addedOn || "").toUpperCase()
                                color: Theme.textFaint
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                            }
                            Item { Layout.fillHeight: true }
                            Pill {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Recognised"
                                tone: Theme.success
                                dot: true
                            }
                        }
                    }
                }
            }

            EmptyState {
                anchors.centerIn: parent
                visible: peopleModel.count === 0
                iconName: "users"
                title: "No identities enrolled"
                message: "Name visitors from History and DoorDarshan will recognise them the next time they come by."
                AppButton {
                    text: "Open history"
                    variant: "primary"
                    iconName: "history"
                    onClicked: Session.navigate("history")
                }
            }
        }
    }

    AppDialog {
        id: removeDialog
        property int targetId: -1
        property string targetName: ""
        title: "Remove " + targetName + "?"
        message: "DoorDarshan will stop recognising them. Their past visits stay in History as unknown visitors."
        iconName: "trash"
        tone: Theme.danger
        destructive: true
        confirmText: "Remove"
        onConfirmed: {
            if (page.db.removeIdentity(targetId)) {
                app.reloadAIIdentities()
                Session.identitiesRevision++
                Session.historyRevision++
                Session.notify(targetName + " removed", "success")
            }
        }
    }
}
