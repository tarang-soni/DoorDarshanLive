import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes

// HUD viewport for the doorbell camera: grayscale ambient backdrop, targeting
// brackets, face callout with a leader line, and status read-outs.
Rectangle {
    id: root

    readonly property var ui: Session.ui
    readonly property bool connected: ui ? ui.piConnected : false
    readonly property bool cameraOn: ui ? ui.cameraUiEnabled : false
    readonly property bool motionOn: ui ? ui.motionEnabled : false
    readonly property bool live: Session.streamLive && cameraOn
    property int frameNo: 0
    property double clock: Date.now()

    radius: 0
    color: Theme.surfaceSunken
    border.width: 1
    border.color: live ? Theme.tint(Theme.accent, 0.45) : Theme.border
    clip: true
    Behavior on border.color { ColorAnimation { duration: Theme.durationSlow } }

    Timer {
        interval: 1000
        running: root.live
        repeat: true
        onTriggered: root.clock = Date.now()
    }

    Connections {
        target: Session.video
        function onFrameReady() {
            if (root.cameraOn)
                feed.source = "image://camera/live?" + (++root.frameNo)
        }
        function onStreamStopped() {
            feed.source = ""
        }
    }

    Item {
        id: viewport
        anchors.fill: parent
        anchors.margins: 1
        visible: root.live

        // Desaturated, blurred copy fills the letterbox bars.
        MultiEffect {
            anchors.fill: parent
            source: feed
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            saturation: -1.0
            brightness: -0.45
            scale: 1.3
        }

        Image {
            id: feed
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            cache: false
            smooth: true
            onStatusChanged: {
                if (status === Image.Ready && sourceSize.width > 0)
                    Session.resolution = sourceSize.width + "×" + sourceSize.height
            }
        }

        // Scanlines
        Canvas {
            anchors.fill: parent
            opacity: 0.5
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.fillStyle = "rgba(0,0,0,0.18)"
                for (let y = 0; y < height; y += 3)
                    ctx.fillRect(0, y, width, 1)
            }
        }

        // Face target, mapped from frame pixels to the painted image area
        Item {
            id: target
            readonly property real scaleX: feed.paintedWidth / Math.max(1, feed.sourceSize.width)
            readonly property real scaleY: feed.paintedHeight / Math.max(1, feed.sourceSize.height)
            readonly property real offsetX: (feed.width - feed.paintedWidth) / 2
            readonly property real offsetY: (feed.height - feed.paintedHeight) / 2
            readonly property color tone: Session.faceKnown ? Theme.success : Theme.warning

            visible: Session.faceVisible && Session.prefs.showFaceOverlay
            x: Session.faceX * scaleX + offsetX
            y: Session.faceY * scaleY + offsetY
            width: Session.faceW * scaleX
            height: Session.faceH * scaleY

            Behavior on x { NumberAnimation { duration: 90 } }
            Behavior on y { NumberAnimation { duration: 90 } }
            Behavior on width { NumberAnimation { duration: 90 } }
            Behavior on height { NumberAnimation { duration: 90 } }

            Rectangle {
                anchors.fill: parent
                color: Theme.tint(target.tone, 0.06)
                border.width: 1
                border.color: Theme.tint(target.tone, 0.35)
            }
            Brackets {
                color: target.tone
                length: Math.min(18, target.width / 4)
                thickness: 2
            }
            Rectangle {
                anchors.centerIn: parent
                width: 9; height: 1
                color: target.tone
            }
            Rectangle {
                anchors.centerIn: parent
                width: 1; height: 9
                color: target.tone
            }

            // Leader line from the top-left corner up to the callout
            Shape {
                x: -46
                y: -34
                width: 46
                height: 34
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeColor: target.tone
                    strokeWidth: 1
                    fillColor: "transparent"
                    startX: 46; startY: 34
                    PathLine { x: 18; y: 6 }
                    PathLine { x: 0; y: 6 }
                }
            }
            Column {
                x: -46 - width
                y: -34 - height / 2 + 6
                spacing: 4
                CalloutTag {
                    text: Session.faceKnown ? Session.faceName : "Unknown"
                    tone: target.tone
                }
                Pill {
                    text: Session.faceKnown ? "Match" : "No match"
                    tone: target.tone
                    solid: true
                }
            }
        }

        // Read-out scrims
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 80
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.rgba(0, 0, 0, 0.6) }
                GradientStop { position: 1; color: "transparent" }
            }
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 100
            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.7) }
            }
        }
    }

    // Viewport frame brackets
    Brackets {
        anchors.margins: 10
        color: root.live ? Theme.accent : Theme.borderStrong
        length: 22
    }

    // Top read-outs
    RowLayout {
        visible: root.live
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 22 }
        spacing: 8

        Pill {
            text: "Rec"
            tone: Theme.live
            dot: true
            pulsing: true
            solid: true
        }
        Pill {
            text: "Cam-01 // Front door"
            tone: Theme.text
            solid: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: Qt.formatDateTime(new Date(root.clock), "yyyy-MM-dd  hh:mm:ss")
            color: Theme.text
            font.family: Theme.fontMono
            font.pixelSize: 12
        }
    }

    // Motion watch callout
    Column {
        visible: root.live && root.motionOn
        anchors { left: parent.left; top: parent.top; leftMargin: 22; topMargin: 58 }
        spacing: 6
        CalloutTag {
            text: "Scanning…"
            tone: Theme.text
        }
        Row {
            spacing: 6
            Rectangle {
                width: 34
                height: 16
                color: Theme.tint(Theme.accent, 0.12)
                border.width: 1
                border.color: Theme.tint(Theme.accent, 0.5)
                Text {
                    anchors.centerIn: parent
                    text: "MTN"
                    color: Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                }
            }
            SegmentMeter {
                id: scanMeter
                anchors.verticalCenter: parent.verticalCenter
                segments: 12
                segmentWidth: 3
                segmentHeight: 12
                animated: true
                SequentialAnimation on value {
                    running: root.live && root.motionOn
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.1; to: 1; duration: 1600; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1; to: 0.1; duration: 1600; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Bottom read-outs
    RowLayout {
        visible: root.live
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 22 }
        spacing: 16

        ColumnLayout {
            spacing: 2
            Text {
                text: "FRONT DOOR"
                color: Theme.text
                font.family: Theme.fontMono
                font.pixelSize: 16
                font.letterSpacing: 2
            }
            Text {
                text: "NODE " + (root.ui ? root.ui.connectedIp : "")
                color: Theme.textMuted
                font.family: Theme.fontMono
                font.pixelSize: 11
            }
        }
        Item { Layout.fillWidth: true }
        ColumnLayout {
            spacing: 4
            Text {
                Layout.alignment: Qt.AlignRight
                text: Session.fps + " FPS · " + (Session.resolution || "—")
                color: Theme.text
                font.family: Theme.fontMono
                font.pixelSize: 11
            }
            SegmentMeter {
                Layout.alignment: Qt.AlignRight
                value: Session.fps / 30
                segments: 20
                segmentWidth: 4
                segmentHeight: 8
            }
        }
    }

    // Empty and waiting states
    EmptyState {
        anchors.centerIn: parent
        visible: !root.connected
        iconName: "door"
        title: "No doorbell linked"
        message: "Find your DoorDarshan Pi on the network to see who's at the door."
        AppButton {
            text: "Set up doorbell"
            variant: "primary"
            iconName: "arrow-right"
            onClicked: Session.navigate("setup")
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: root.connected && !root.cameraOn
        iconName: "camera-off"
        tone: root.motionOn ? Theme.accent : Theme.textMuted
        title: root.motionOn ? "Camera off · motion armed" : "Camera offline"
        message: root.motionOn
                 ? "Motion watch is running in the background. You'll be alerted when someone lingers."
                 : "Turn the camera on to watch your front door live."
        AppButton {
            text: "Camera on"
            variant: "primary"
            iconName: "camera"
            onClicked: Session.setCamera(true)
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        visible: root.connected && root.cameraOn && !root.live
        spacing: 14
        BusySpinner {
            Layout.alignment: Qt.AlignHCenter
            size: 32
            lineWidth: 2
            color: Theme.accent
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "> negotiating video stream_"
            color: Theme.textMuted
            font.family: Theme.fontMono
            font.pixelSize: 12
        }
    }
}
