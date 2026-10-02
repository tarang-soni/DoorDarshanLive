import QtQuick
import QtQuick.Controls.Basic
import Qt.labs.platform as Platform

Window {
    id: mainWindow

    width: 1360
    height: 840
    minimumWidth: 1140
    minimumHeight: 720
    visible: true
    title: qsTr("DoorDarshan")
    color: Theme.bg

    property string currentPage: "dashboard"

    function navigate(page) {
        if (page === currentPage || !pages[page])
            return
        currentPage = page
        stack.replace(null, pages[page])
    }

    // Restore without un-maximising a maximised window.
    function bringToFront() {
        if (mainWindow.visibility === Window.Minimized || mainWindow.visibility === Window.Hidden)
            mainWindow.showNormal()
        mainWindow.show()
        mainWindow.raise()
        mainWindow.requestActivate()
    }

    readonly property var pages: ({
        dashboard: dashboardPage,
        history: historyPage,
        people: peoplePage,
        setup: setupPage,
        settings: settingsPage
    })

    Component { id: dashboardPage; DashboardScreen {} }
    Component { id: historyPage; HistoryScreen {} }
    Component { id: peoplePage; PeopleScreen {} }
    Component { id: setupPage; DeviceSetupScreen {} }
    Component { id: settingsPage; SettingsScreen {} }

    // Faint HUD grid behind everything
    Canvas {
        id: gridCanvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = Theme.grid
            ctx.lineWidth = 1
            const step = 40
            ctx.beginPath()
            for (let x = 0.5; x < width; x += step) { ctx.moveTo(x, 0); ctx.lineTo(x, height) }
            for (let y = 0.5; y < height; y += step) { ctx.moveTo(0, y); ctx.lineTo(width, y) }
            ctx.stroke()
        }
    }

    Sidebar {
        id: sidebar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        currentPage: mainWindow.currentPage
        onNavigate: (page) => mainWindow.navigate(page)
    }

    StackView {
        id: stack
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 32
            topMargin: 30
        }
        initialItem: dashboardPage

        replaceEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
                NumberAnimation { property: "y"; from: 14; to: 0; duration: 260; easing.type: Easing.OutCubic }
            }
        }
        replaceExit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120 }
        }
    }

    ToastHost {
        id: toasts
        anchors.fill: parent
        z: 100
    }

    Connections {
        target: Session
        function onNavigateRequested(page) { mainWindow.navigate(page) }
        function onToastRequested(message, kind) { toasts.show(message, kind) }
        function onVisitorAlert(who) {
            if (Session.prefs.desktopNotifications)
                tray.showMessage("Someone's at the door", who + " is at your front door.",
                                 Platform.SystemTrayIcon.Information, 5000)
            if (Session.prefs.raiseOnAlert) {
                mainWindow.bringToFront()
                Session.setCamera(true)
                mainWindow.navigate("dashboard")
            }
            toasts.show(who + " is at the door", "warning")
        }
    }

    Platform.SystemTrayIcon {
        id: tray
        visible: true
        icon.source: "qrc:/qt/qml/qt_DoorDarshanLive/resources/images/tray.png"
        tooltip: "DoorDarshan"

        onMessageClicked: {
            mainWindow.bringToFront()
            mainWindow.navigate("dashboard")
        }
        onActivated: (reason) => {
            if (reason === Platform.SystemTrayIcon.Trigger || reason === Platform.SystemTrayIcon.DoubleClick)
                mainWindow.bringToFront()
        }

        menu: Platform.Menu {
            Platform.MenuItem {
                text: "Open DoorDarshan"
                onTriggered: mainWindow.bringToFront()
            }
            Platform.MenuItem {
                text: "Quit"
                onTriggered: Qt.quit()
            }
        }
    }
}
