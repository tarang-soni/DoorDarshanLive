import QtQuick
import QtQuick.Layouts

// Square panel with an uppercase label row and a ↗ corner glyph.
// Without a fixed height, the card sizes itself to its body's children.
Rectangle {
    id: root

    default property alias contentData: body.data
    property alias actions: actionRow.data
    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property int padding: 16
    property bool hoverable: false
    property bool showGlyph: true
    readonly property bool hovered: hover.hovered

    readonly property real headerHeight: header.visible ? header.implicitHeight + 14 : 0
    readonly property real bodyImplicitHeight: {
        let h = 0
        for (let i = 0; i < body.children.length; ++i)
            h = Math.max(h, body.children[i].implicitHeight)
        return h
    }

    implicitHeight: padding + headerHeight + bodyImplicitHeight + padding
    radius: 0
    color: Theme.surface
    border.width: 1
    border.color: hoverable && hover.hovered ? Theme.borderStrong : Theme.border

    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

    HoverHandler { id: hover }

    RowLayout {
        id: header
        visible: root.title !== ""
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: root.padding
            leftMargin: root.padding
            rightMargin: root.padding
        }
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: 12
                font.letterSpacing: Theme.labelSpacing
                font.capitalization: Font.AllUppercase
            }
            Text {
                visible: root.subtitle !== ""
                Layout.fillWidth: true
                text: root.subtitle
                color: Theme.textFaint
                font.family: Theme.fontMono
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }
        }
        Row {
            id: actionRow
            spacing: 8
            Layout.alignment: Qt.AlignTop
        }
        Rectangle {
            visible: root.showGlyph && actionRow.children.length === 0
            Layout.alignment: Qt.AlignTop
            implicitWidth: 20
            implicitHeight: 20
            color: "transparent"
            border.width: 1
            border.color: Theme.border
            Text {
                anchors.centerIn: parent
                text: "↗"
                color: Theme.textFaint
                font.family: Theme.fontMono
                font.pixelSize: 11
            }
        }
    }

    Item {
        id: body
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: root.padding + root.headerHeight
            leftMargin: root.padding
            rightMargin: root.padding
            bottomMargin: root.padding
        }
    }
}
