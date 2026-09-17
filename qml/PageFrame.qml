import QtQuick

Item {
    id: root

    property alias headerContent:headerArea.data
    property alias content:contentArea.data

    Rectangle{
        id:topBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: parent.height*.1
        color:Theme.primary_theme_color
        CustomBorder{
            id:topBarBorder
            borderColor: Theme.border_theme_color
            tborderWidth: 1
            rborderWidth: 1
            lborderWidth: 0
            bborderWidth: 1
        }
        Item {
            id: headerArea
            anchors.fill: parent
        }
    }
    Rectangle{
        id:mainPage
        CustomBorder{
            id:mainPageBorder
            borderColor: Theme.border_theme_color
            tborderWidth: 0
            rborderWidth: 1
            lborderWidth: 0
            bborderWidth: 1
        }
        anchors{
            top:topBar.bottom
            bottom:parent.bottom
            left:parent.left
            right:parent.right

        }
        color:Theme.primary_theme_color

        Item {
            id: contentArea
            anchors.fill: parent
        }
    }
}
