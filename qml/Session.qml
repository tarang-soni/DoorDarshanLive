pragma Singleton
import QtQuick
import QtCore

// App-wide UI state that must outlive page switches: live stream stats, the
// latest face, discovered doorbells, the activity log, and saved preferences.
// Visitor alerts are handled here so they fire whichever page is open.
QtObject {
    id: session

    readonly property var ui: app ? app.uiManager : null
    readonly property var video: app ? app.videoBridge : null
    readonly property var db: app ? app.databaseManager : null

    signal toastRequested(string message, string kind)
    signal navigateRequested(string page)
    signal visitorAlert(string who)

    // Live stream
    property int fps: 0
    property int _frames: 0
    property var fpsHistory: []
    readonly property bool streamLive: fps > 0
    property string resolution: ""

    // Most recent face reported by the AI worker
    property bool faceVisible: false
    property int faceX: 0
    property int faceY: 0
    property int faceW: 0
    property int faceH: 0
    property string faceName: ""
    readonly property bool faceKnown: faceName !== "" && faceName !== "Unknown"

    // Bumped whenever stored data changes so pages know to reload
    property int historyRevision: 0
    property int identitiesRevision: 0

    // Connection flow
    property string connectingIp: ""
    property bool scanning: false
    property ListModel devices: ListModel {}

    property ListModel activity: ListModel {}
    property double now: Date.now()

    property Settings prefs: Settings {
        location: StandardPaths.writableLocation(StandardPaths.AppConfigLocation) + "/ui.ini"
        property bool showFaceOverlay: true
        property bool desktopNotifications: true
        property bool raiseOnAlert: true
        property string lastPiIp: ""
    }

    function notify(message, kind) {
        toastRequested(message, kind || "info")
    }

    function log(text, kind, tag) {
        activity.insert(0, { text: text, kind: kind || "muted", tag: tag || "EVENT", at: Date.now() })
        if (activity.count > 60)
            activity.remove(60, activity.count - 60)
    }

    function navigate(page) {
        navigateRequested(page)
    }

    function relativeTime(ms) {
        const seconds = Math.max(0, Math.round((now - ms) / 1000))
        if (seconds < 45) return "just now"
        const minutes = Math.round(seconds / 60)
        if (minutes < 60) return minutes + " min ago"
        const hours = Math.round(minutes / 60)
        if (hours < 24) return hours + " h ago"
        const days = Math.round(hours / 24)
        return days === 1 ? "yesterday" : days + " days ago"
    }

    function takeSnapshot() {
        if (!streamLive) {
            notify("Turn on the camera to take a snapshot", "warning")
            return
        }
        app.takeManualSnapshot()
        historyRevision++
        log("Snapshot saved to history", "accent", "SNAPSHOT")
        notify("Snapshot saved to History", "success")
    }

    function setCamera(on) {
        if (ui) ui.cameraUiEnabled = on
    }

    function setMotion(on) {
        if (ui) ui.motionEnabled = on
    }

    function scan() {
        if (!ui) return
        devices.clear()
        if (ui.piConnected && ui.connectedIp !== "")
            devices.append({ ip: ui.connectedIp })
        scanning = true
        ui.findDevices()
        log("Broadcasting DD_DISCOVERY on the local network", "info", "SCAN_START")
    }

    function connectTo(ip) {
        if (!ui || ip === "") return
        if (ui.piConnected && ui.connectedIp === ip) return
        if (ui.piConnected) ui.disconnectPi()
        connectingIp = ip
        connectTimeout.restart()
        ui.connectToPi(ip)
        log("Requesting control link from " + ip, "info", "LINK_REQUEST")
    }

    function reconnect() {
        if (!ui) return
        const ip = ui.connectedIp !== "" ? ui.connectedIp : prefs.lastPiIp
        if (ip === "") {
            notify("No doorbell to reconnect to. Scan for one first.", "warning")
            navigate("setup")
            return
        }
        if (ui.piConnected) ui.disconnectPi()
        connectTo(ip)
    }

    function disconnect() {
        if (ui) ui.disconnectPi()
    }

    property Timer fpsTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            session.fps = session._frames
            session._frames = 0
            const history = session.fpsHistory.concat([session.fps])
            session.fpsHistory = history.length > 60 ? history.slice(history.length - 60) : history
            if (session.fps === 0)
                session.faceVisible = false
        }
    }

    property Timer clockTimer: Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: session.now = Date.now()
    }

    property Timer connectTimeout: Timer {
        interval: 10000
        onTriggered: {
            if (session.connectingIp === "") return
            session.notify("Couldn't reach the doorbell at " + session.connectingIp, "danger")
            session.log("No answer from " + session.connectingIp, "danger", "LINK_TIMEOUT")
            session.connectingIp = ""
        }
    }

    property Connections uiConnections: Connections {
        target: session.ui

        function onPiConnectedChanged() {
            const ui = session.ui
            if (ui.piConnected) {
                session.connectingIp = ""
                session.connectTimeout.stop()
                if (ui.connectedIp !== "")
                    session.prefs.lastPiIp = ui.connectedIp
                session.log("Doorbell connected" + (ui.connectedIp ? " at " + ui.connectedIp : ""), "success", "LINK_UP")
                session.notify("Doorbell connected", "success")
            } else {
                session.fps = 0
                session.faceVisible = false
                session.log("Doorbell disconnected", "danger", "LINK_DOWN")
            }
        }
        function onIsStreamingChanged() {
            session.log(session.ui.isStreaming ? "RTP/JPEG stream started" : "Stream stopped",
                        session.ui.isStreaming ? "accent" : "muted",
                        session.ui.isStreaming ? "STREAM_ON" : "STREAM_OFF")
        }
        function onCameraUiEnabledChanged() {
            session.log(session.ui.cameraUiEnabled ? "Camera turned on" : "Camera turned off", "muted", session.ui.cameraUiEnabled ? "CAM_ON" : "CAM_OFF")
        }
        function onMotionEnabledChanged() {
            session.log(session.ui.motionEnabled ? "Motion watch armed" : "Motion watch disarmed", "info", session.ui.motionEnabled ? "MOTION_ARMED" : "MOTION_OFF")
        }
        function onDeviceFound(ip) {
            for (let i = 0; i < session.devices.count; ++i)
                if (session.devices.get(i).ip === ip)
                    return
            session.devices.append({ ip: ip })
            session.log("Doorbell answered from " + ip, "success", "DEVICE_FOUND")
        }
        function onDeviceDiscoveryStopped() {
            session.scanning = false
            if (session.devices.count === 0)
                session.notify("No doorbells found on this network", "warning")
        }
    }

    property Connections videoConnections: Connections {
        target: session.video

        function onFrameReady() {
            session._frames++
        }
        function onFaceDetected(x, y, w, h, name) {
            session.faceX = x
            session.faceY = y
            session.faceW = w
            session.faceH = h
            session.faceName = name
            session.faceVisible = true
        }
        function onFaceLost() {
            session.faceVisible = false
        }
        function onStreamStopped() {
            session.faceVisible = false
            session.fps = 0
        }
        function onMotionAlertTriggered() {
            const who = session.faceVisible && session.faceKnown ? session.faceName : "Someone you don't know"
            app.takeManualSnapshot()
            session.historyRevision++
            session.log(who + " is at the door", session.faceKnown ? "success" : "warning", session.faceKnown ? "VISITOR_KNOWN" : "VISITOR_UNKNOWN")
            session.visitorAlert(who)
        }
    }
}
