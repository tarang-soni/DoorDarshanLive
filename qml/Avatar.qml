import QtQuick

// Square portrait in a targeting frame; initials when there is no photo.
Item {
    id: root

    property string name: ""
    property string source: ""
    property real size: 56
    property color tone: Theme.accent

    implicitWidth: size
    implicitHeight: size

    readonly property string initials: {
        const parts = name.trim().split(/\s+/).filter(p => p.length > 0)
        if (parts.length === 0)
            return "?"
        if (parts.length === 1)
            return parts[0].substring(0, 2).toUpperCase()
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 5
        color: Theme.tint(root.tone, 0.07)
        border.width: 1
        border.color: Theme.tint(root.tone, 0.25)

        Text {
            anchors.centerIn: parent
            text: root.initials
            color: root.tone
            font.family: Theme.fontMono
            font.pixelSize: root.size * 0.3
            font.weight: Font.Light
            font.letterSpacing: 2
        }

        RoundedImage {
            anchors.fill: parent
            source: Theme.fileUrl(root.source)
            visible: status === Image.Ready
        }
    }

    Brackets {
        color: root.tone
        length: Math.max(8, root.size * 0.16)
    }
}
