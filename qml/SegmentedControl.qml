import QtQuick

// Square tab switcher with a sliding highlight.
// model: [{ key: "all", label: "All" }, ...]
Rectangle {
    id: root

    property var model: []
    property string current: model.length > 0 ? model[0].key : ""

    signal activated(string key)

    implicitHeight: 36
    implicitWidth: row.implicitWidth + 6
    radius: 0
    color: Theme.surfaceSunken
    border.width: 1
    border.color: Theme.borderStrong

    readonly property int currentIndex: {
        for (let i = 0; i < model.length; ++i)
            if (model[i].key === current)
                return i
        return 0
    }

    Rectangle {
        readonly property Item target: repeater.count > root.currentIndex ? repeater.itemAt(root.currentIndex) : null
        x: target ? row.x + target.x : 3
        y: 3
        width: target ? target.width : 0
        height: parent.height - 6
        radius: 0
        color: Theme.tint(Theme.accent, 0.12)
        border.width: 1
        border.color: Theme.accent
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        x: 3

        Repeater {
            id: repeater
            model: root.model

            Item {
                id: segment
                required property var modelData
                required property int index
                readonly property bool active: index === root.currentIndex

                width: label.implicitWidth + 28
                height: root.height - 6

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: segment.modelData.label
                    color: segment.active ? Theme.accent : Theme.textMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.letterSpacing: 1.2
                    font.capitalization: Font.AllUppercase
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.current = segment.modelData.key
                        root.activated(segment.modelData.key)
                    }
                }
            }
        }
    }
}
