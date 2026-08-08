import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
Rectangle{
    id:root

    width:parent.width*.2
    anchors {
        left: parent.left
        top: parent.top
        bottom: parent.bottom
    }
    color:Theme.primary_theme_color
    border.width: 1
    border.color: Theme.border_theme_color
    signal screenSelected(string pagePath)
    Item{
        id:appHeader
        anchors{
            left:parent.left
            right:parent.right
            top:parent.top
        }
        height:72


        Label  {
            anchors.fill: parent

            text: "[Door-Darshan]"
            color: Theme.normal_text_theme_color

            font.family: Theme.jetbrainsFont
            font.pixelSize: 24

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    Item{
        id:sidebarContent
        anchors{
            top: appHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        ListView{
            id:listView
            anchors.fill:parent
            clip:true

            model: [
                { text: "Dashboard", page: "qml/DashboardScreen.qml" },
                { text: "History", page: "qml/HistoryScreen.qml" },
                { text: "Device Setup", page: "qml/DeviceSetupScreen.qml" },
                { text: "Settings", page: "qml/SettingsScreen.qml" }
            ]
            spacing:5

            delegate:
                Item{
                id: delegateRoot
                readonly property bool isLastItem:index == listView.count-1
                required property var modelData
                required property int index
                height:isLastItem?Math.max(sideBtn.height,listView.height-((listView.count-1)*(sideBtn.height+listView.spacing))):sideBtn.height
                SidebarButton
                {
                    id:sideBtn

                    width: listView.width
                    height: 60
                    color:"transparent"
                    text: delegateRoot.modelData.text
                    isSelected:delegateRoot.ListView.isCurrentItem

                    anchors.bottom: parent.isLastItem ? parent.bottom : undefined
                    anchors.top: parent.isLastItem ? undefined : parent.top
                    onClicked:{
                        listView.currentIndex=delegateRoot.index
                        screenSelected(delegateRoot.modelData.page)
                    }

                }
            }

        }

    }

}