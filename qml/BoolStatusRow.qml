import QtQuick

StatusRow
{
    property string trueValue:"Connected"
    property string falseValue:"Disconnected"
    property bool isOn:false
    property color trueColor:Theme.status_green
    property color falseColor:Theme.status_red

    valueColor:isOn?trueColor:falseColor
    value:isOn?trueValue:falseValue
}
