import QtQuick
import QtQuick.Layouts

// Label + large thin numeral, optionally with a segment meter.
Rectangle {
    id: root

    property string label: ""
    property string value: "—"
    property string unit: ""
    property string iconName: ""
    property color tone: Theme.accent
    property real meter: -1

    implicitHeight: 92
    radius: 0
    color: Theme.surface
    border.width: 1
    border.color: Theme.border

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 4

        RowLayout {
            Text {
                Layout.fillWidth: true
                text: root.label
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: 11
                font.letterSpacing: Theme.labelSpacing
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
            }
            Rectangle {
                implicitWidth: 6
                implicitHeight: 6
                color: root.tone
            }
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            spacing: 4
            Text {
                Layout.alignment: Qt.AlignBaseline
                text: root.value
                color: Theme.text
                font.family: Theme.fontMono
                font.pixelSize: 30
                font.weight: Font.Light
            }
            Text {
                visible: root.unit !== ""
                Layout.alignment: Qt.AlignBaseline
                text: root.unit
                color: Theme.textFaint
                font.family: Theme.fontMono
                font.pixelSize: 12
            }
        }
        SegmentMeter {
            visible: root.meter >= 0
            value: root.meter
            segments: 18
            segmentWidth: 5
            segmentHeight: 6
            tone: root.tone
        }
    }
}
