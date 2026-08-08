import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
Rectangle
{
    id:root
    height: 60
    color:"red"
    property string text:""
    property bool isSelected:false
    property int fontSize:20
    signal clicked()
    Label{
        id:btnLabel
        text:"<"+root.text+">"
        color:isSelected?Theme.selectedBtn_text_theme_color:Theme.normal_text_theme_color
        font.pixelSize: fontSize
        anchors.centerIn:parent
        font.family:Theme.jetbrainsFont
    }
    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            btnLabel.text = "<  "+root.text+"  >"
        }
        onExited:
        {
            btnLabel.text = "<"+root.text+">"
        }
        onClicked: root.clicked()

    }

}
