import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qml"
import "qml/Dashboard"
import Qt.labs.platform

Window {
    id: mainWindow // <--- CHANGED FROM 'root' TO 'mainWindow'

    width: 1280
    height: 720
    visible: true
    title: qsTr("DoorDarshan")

    Component.onCompleted: {
        console.log("Main completed", this)
    }

    function forceRestoreWindow() {
        mainWindow.visibility = Window.Windowed
        mainWindow.show()
        mainWindow.raise()
        mainWindow.requestActivate()
        if (app && app.uiManager) {
                    app.uiManager.cameraUiEnabled = true;
                }
    }

    SystemTrayIcon {
        id: appTrayIcon
        visible: true
        tooltip: "DoorDarshan Security"

        onMessageClicked: forceRestoreWindow()

        menu: Menu {
            MenuItem {
                text: "Open DoorDarshan"
                onTriggered: forceRestoreWindow()
            }
            MenuItem {
                text: "Quit"
                onTriggered: Qt.quit()
            }
        }

        onActivated: function(reason) {
            if (reason === SystemTrayIcon.Trigger || reason === SystemTrayIcon.DoubleClick) {
                forceRestoreWindow()
            }
        }
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