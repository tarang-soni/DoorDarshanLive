pragma Singleton
import QtQuick

QtObject {
    id: theme
    readonly property FontLoader jetbrainsFontLoader: FontLoader {
            source: "qrc:/qt/qml/qt_DoorDarshanLive/resources/fonts/JetBrainsMono-VariableFont_wght.ttf"
        }
    readonly property string jetbrainsFont: jetbrainsFontLoader.name
    readonly property color primary_theme_color:"#151515"
    readonly property color border_theme_color:"#555555"
    readonly property color normal_text_theme_color:"white"
    readonly property color selectedBtn_text_theme_color:"green"
    readonly property color status_green:"#6FCF97"
    readonly property color status_yellow:"#F2C94C"
    readonly property color status_red:"red"
}