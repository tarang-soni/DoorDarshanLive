import QtQuick

// Framed image with a placeholder while loading or missing.
Item {
    id: root

    property alias source: img.source
    property alias status: img.status
    property int fillMode: Image.PreserveAspectCrop
    property string placeholderIcon: "image"

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceSunken
        border.width: 1
        border.color: Theme.border

        AppIcon {
            anchors.centerIn: parent
            visible: img.status !== Image.Ready
            name: root.placeholderIcon
            color: Theme.textFaint
            size: Math.min(26, parent.height * 0.3)
        }
    }

    Image {
        id: img
        anchors.fill: parent
        anchors.margins: 1
        fillMode: root.fillMode
        asynchronous: true
        smooth: true
        mipmap: true
        clip: true
        sourceSize.width: 720
    }
}
