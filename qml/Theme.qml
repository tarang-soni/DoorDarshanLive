pragma Singleton
import QtQuick

// Terminal / HUD look: near-black panels, hairline borders, square corners,
// monospace type and a single mint accent.
QtObject {
    id: theme

    readonly property FontLoader monoLoader: FontLoader {
        source: "qrc:/qt/qml/qt_DoorDarshanLive/resources/fonts/JetBrainsMono-VariableFont_wght.ttf"
    }
    readonly property string fontMono: monoLoader.name
    readonly property string fontSans: monoLoader.name

    // Surfaces, darkest to lightest
    readonly property color bg: "#060707"
    readonly property color sidebar: "#080A0A"
    readonly property color surfaceSunken: "#040505"
    readonly property color surface: "#0B0D0D"
    readonly property color surfaceRaised: "#101313"
    readonly property color surfaceHover: "#151919"
    readonly property color border: "#1E2323"
    readonly property color borderStrong: "#2F3737"
    readonly property color grid: Qt.rgba(1, 1, 1, 0.028)

    // Text
    readonly property color text: "#E2E8E6"
    readonly property color textMuted: "#8A9592"
    readonly property color textFaint: "#4F5957"

    // Accent
    readonly property color accent: "#66E3C4"
    readonly property color accentDim: "#1E3D36"
    readonly property color accentAlt: "#7FC8F8"

    // Status
    readonly property color success: "#66E3C4"
    readonly property color warning: "#F2B544"
    readonly property color danger: "#FF5D6C"
    readonly property color live: "#FF4D5E"
    readonly property color info: "#7FC8F8"

    // Square corners everywhere
    readonly property int radiusSm: 0
    readonly property int radiusMd: 0
    readonly property int radiusLg: 0
    readonly property int radiusXl: 0

    readonly property int durationFast: 120
    readonly property int durationNormal: 200
    readonly property int durationSlow: 320

    readonly property real labelSpacing: 1.6

    function tint(c, alpha) {
        return Qt.rgba(c.r, c.g, c.b, alpha)
    }

    // Maps an activity/event kind to its colour.
    function tone(kind) {
        switch (kind) {
        case "success": return success
        case "warning": return warning
        case "danger": return danger
        case "accent": return accent
        case "info": return info
        default: return textMuted
        }
    }

    // Zero-padded number, e.g. pad(7, 3) -> "007"
    function pad(n, width) {
        let s = String(n)
        while (s.length < width)
            s = "0" + s
        return s
    }

    // Local file path -> URL usable by Image, on both Windows and Unix paths.
    function fileUrl(path) {
        if (!path)
            return ""
        return path.startsWith("/") ? "file://" + path : "file:///" + path
    }
}
