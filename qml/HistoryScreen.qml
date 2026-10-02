import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: page

    readonly property var db: Session.db
    property string filter: "all"
    property int totalCount: 0
    property int knownCount: 0

    ListModel { id: historyModel }

    function reload() {
        historyModel.clear()
        const logs = db ? db.getHistoryLogs() : []
        let known = 0
        for (let i = 0; i < logs.length; ++i) {
            const log = logs[i]
            if (log.isKnown) known++
            if (filter === "all" || (filter === "known") === log.isKnown)
                historyModel.append(log)
        }
        totalCount = logs.length
        knownCount = known
    }

    onFilterChanged: reload()
    Component.onCompleted: reload()

    Connections {
        target: Session
        function onHistoryRevisionChanged() { page.reload() }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 22

        PageHeader {
            Layout.fillWidth: true
            path: "history"
            title: "History"
            subtitle: page.totalCount === 0 ? "snapshots of everyone who came to the door."
                                            : page.totalCount + (page.totalCount === 1 ? " record" : " records")
                                              + " · " + page.knownCount + " recognised"

            SegmentedControl {
                current: page.filter
                model: [
                    { key: "all", label: "All" },
                    { key: "known", label: "Known" },
                    { key: "unknown", label: "Unknown" }
                ]
                onActivated: (key) => page.filter = key
            }
            AppButton {
                variant: "danger"
                text: "Clear all"
                iconName: "trash"
                enabled: page.totalCount > 0
                onClicked: clearDialog.open()
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
                model: historyModel
                boundsBehavior: Flickable.StopAtBounds
                readonly property int columns: Math.max(1, Math.floor(width / 300))
                cellWidth: Math.floor(width / columns)
                cellHeight: Math.round((cellWidth - 34) * 0.56) + 112
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                // The model has an "id" role, which can't be a QML property, so read roles via `model`.
                delegate: SnapshotCard {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    entryId: model.id
                    imagePath: model.imagePath
                    visitorName: model.visitorName
                    isKnown: model.isKnown
                    timestamp: model.timestamp
                    iso: model.iso || ""

                    onPreviewRequested: preview.show(imagePath, isKnown ? visitorName : "Unknown visitor", timestamp)
                    onNameRequested: nameDialog.openFor(entryId, imagePath)
                    onDeleteRequested: {
                        deleteDialog.targetId = entryId
                        deleteDialog.open()
                    }
                }
            }

            EmptyState {
                anchors.centerIn: parent
                visible: historyModel.count === 0
                iconName: "history"
                title: page.totalCount === 0 ? "No visitors yet" : "Nothing in this filter"
                message: page.totalCount === 0
                         ? "Snapshots appear here when someone lingers at the door or you press Snapshot on the live view."
                         : "Try a different filter to see the rest of your history."
                AppButton {
                    visible: page.totalCount === 0
                    text: "Open live view"
                    iconName: "dashboard"
                    onClicked: Session.navigate("dashboard")
                }
            }
        }
    }

    AppDialog {
        id: clearDialog
        title: "Clear all history?"
        message: "This removes all " + page.totalCount + " snapshots from History. People you've already named stay saved."
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

    AppDialog {
        id: deleteDialog
        property int targetId: -1
        title: "Delete this snapshot?"
        message: "It will be removed from History. This can't be undone."
        iconName: "trash"
        tone: Theme.danger
        destructive: true
        confirmText: "Delete"
        onConfirmed: {
            if (page.db.deleteHistoryLog(targetId)) {
                Session.historyRevision++
                Session.notify("Snapshot deleted", "success")
            }
        }
    }

    AppDialog {
        id: nameDialog
        property int targetId: -1
        property string targetImage: ""

        function openFor(id, imagePath) {
            targetId = id
            targetImage = imagePath
            nameField.text = ""
            open()
            nameField.forceActiveFocus()
        }

        function save() {
            const name = nameField.text.trim()
            if (name === "") return
            if (page.db.nameUnknownVisitor(targetId, name)) {
                app.reloadAIIdentities()
                Session.identitiesRevision++
                Session.historyRevision++
                Session.notify("Saved " + name + ". DoorDarshan will recognise them next time.", "success")
            } else {
                Session.notify("Couldn't save that name", "danger")
            }
        }

        title: "Who is this?"
        message: "Give this visitor a name and DoorDarshan will greet them by name next time."
        iconName: "user-plus"
        confirmText: "Save person"
        confirmEnabled: nameField.text.trim() !== ""
        onConfirmed: save()

        RoundedImage {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            source: Theme.fileUrl(nameDialog.targetImage)
        }
        TextField {
            id: nameField
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            placeholderText: "> name, e.g. Rahul (Swiggy)"
            placeholderTextColor: Theme.textFaint
            color: Theme.text
            font.family: Theme.fontMono
            font.pixelSize: 13
            leftPadding: 14
            selectByMouse: true
            selectionColor: Theme.tint(Theme.accent, 0.5)
            cursorDelegate: Rectangle {
                width: 8
                color: Theme.accent
                visible: nameField.activeFocus
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1; duration: 0 }
                    PauseAnimation { duration: 530 }
                    NumberAnimation { to: 0; duration: 0 }
                    PauseAnimation { duration: 530 }
                }
            }
            background: Rectangle {
                radius: 0
                color: Theme.surfaceSunken
                border.width: 1
                border.color: nameField.activeFocus ? Theme.accent : Theme.borderStrong
            }
            onAccepted: {
                if (nameDialog.confirmEnabled) {
                    nameDialog.save()
                    nameDialog.close()
                }
            }
        }
    }

    // Full-size snapshot viewer
    Popup {
        id: preview
        property string imagePath: ""
        property string caption: ""
        property string when: ""

        function show(path, who, stamp) {
            imagePath = path
            caption = who
            when = stamp
            open()
        }

        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(parent.width - 120, 980)
        height: Math.min(parent.height - 120, 720)
        padding: 0
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle { color: Qt.rgba(0, 0, 0, 0.85) }
        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 160 }
                NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: 220; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition { NumberAnimation { property: "opacity"; to: 0; duration: 120 } }

        background: Rectangle {
            radius: 0
            color: Theme.surfaceSunken
            border.width: 1
            border.color: Theme.borderStrong
            Brackets { color: Theme.accent; length: 18 }
        }

        contentItem: Item {
            RoundedImage {
                anchors.fill: parent
                anchors.margins: 14
                fillMode: Image.PreserveAspectFit
                source: Theme.fileUrl(preview.imagePath)
            }
            ColumnLayout {
                anchors { left: parent.left; bottom: parent.bottom; margins: 30 }
                spacing: 0
                CalloutTag {
                    text: preview.caption
                    tone: Theme.accent
                    fontSize: 14
                }
                Text {
                    topPadding: 6
                    text: preview.when
                    color: Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                }
            }
            AppButton {
                anchors { right: parent.right; top: parent.top; margins: 22 }
                variant: "secondary"
                iconName: "close"
                onClicked: preview.close()
            }
        }
    }
}
