import QtQuick

Item {
    property int tborderWidth:0
    property int bborderWidth:0
    property int lborderWidth:0
    property int rborderWidth:0

    property string borderColor:"white"
    anchors.fill: parent
    Rectangle{
        id:topBorder
        anchors{
            top:parent.top
            left:parent.left
            right:parent.right
        }
        height:tborderWidth
        color:borderColor
    }
    Rectangle{
        id:bottomBorder
        anchors{
            bottom:parent.bottom
            left:parent.left
            right:parent.right
        }
        height:bborderWidth
        color:borderColor
    }
    Rectangle{
        id:leftBorder
        anchors{
            top:parent.top
            bottom:parent.bottom
            left:parent.left

        }
        width:lborderWidth
        color:borderColor
    }
    Rectangle{
        id:rightBorder
        anchors{
            top:parent.top
            bottom:parent.bottom
            right:parent.right
        }
        width:rborderWidth
        color:borderColor
    }


}
