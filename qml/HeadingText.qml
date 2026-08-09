import QtQuick
import QtQuick.Controls.Basic

Label {
    id: root

    property string headingTxt: ""
    property string glyph: "#"
    property bool mirror:false
    color: Theme.normal_text_theme_color
    font.pixelSize: 24
    font.family: Theme.jetbrainsFont
    readonly property string mirrorRightGlyph:{
        switch(glyph)
        {
            case "<": return ">"
            case "[": return "]"
            case "{": return "}"
            case "(": return ")"
            default:  return glyph
        }
    }

    text: {
            if (glyph === "") return headingTxt
            return mirror ? `${glyph} ${headingTxt} ${mirrorRightGlyph}` : `${glyph} ${headingTxt}`
        }
}