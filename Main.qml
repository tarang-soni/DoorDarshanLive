import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qml"
import "qml/Dashboard"

Window {
    id: root

    width: 1280
    height: 720
    visible: true
    title: qsTr("Hello World")

    Component.onCompleted: {
        console.log("Main completed", this)
    }

    Item {
        anchors.fill: parent

        SidePanel {
            id: sidebar
            onScreenSelected:
                (pageUrl)=>{
                    stackView.replace(Qt.resolvedUrl(pageUrl));
                }
        }

        StackView {
            id: stackView

            anchors {
                top: parent.top
                left: sidebar.right
                right: parent.right
                bottom: parent.bottom
            }
            pushEnter: null
            pushExit: null
            popEnter: null
            popExit: null
            replaceEnter: null
            replaceExit: null
            initialItem: DashboardScreen {}
        }
    }
}