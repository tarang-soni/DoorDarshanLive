cmake_minimum_required(VERSION 3.16)

project(qt_DoorDarshanLive VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(OpenCV_DIR "D:/Dev/Environments/MSYS2/mingw64/lib/cmake/opencv4")
find_package(OpenCV REQUIRED)

find_package(Qt6 REQUIRED COMPONENTS Quick Network Sql)

qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(appqt_DoorDarshanLive
    main.cpp
)
set_source_files_properties(qml/Theme.qml qml/Session.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)
target_compile_definitions(appqt_DoorDarshanLive PRIVATE
    DD_APP_VERSION="${PROJECT_VERSION}"
)

qt_add_qml_module(appqt_DoorDarshanLive
    URI qt_DoorDarshanLive

    SOURCES
        src/core/appcontroller.h
        src/core/appcontroller.cpp
        src/core/databasemanager.h
        src/core/databasemanager.cpp
        src/core/utils.h

        src/network/Protocol.h
        src/network/discoveryservice.h
        src/network/discoveryservice.cpp
        src/network/networkmanager.h
        src/network/networkmanager.cpp
        src/network/tcpconnector.h
        src/network/tcpconnector.cpp

        src/ui/uimanager.h
        src/ui/uimanager.cpp

        src/video/faceai.h
        src/video/videobridge.h
        src/video/videobridge.cpp
        src/video/cameraimageprovider.h
        src/video/cameraimageprovider.cpp
        src/video/snapshotmanager.h
        src/video/snapshotmanager.cpp

    RESOURCES
        resources/fonts/JetBrainsMono-VariableFont_wght.ttf
        resources/fonts/Saira-VariableFont_wdth,wght.ttf
        resources/images/app-icon.png
        resources/images/tray.png

    QML_FILES
        Main.qml

        # App-wide state
        qml/Theme.qml
        qml/Session.qml

        # Screens
        qml/Sidebar.qml
        qml/DashboardScreen.qml
        qml/HistoryScreen.qml
        qml/PeopleScreen.qml
        qml/DeviceSetupScreen.qml
        qml/SettingsScreen.qml

        # Screen sections
        qml/LiveFeedCard.qml
        qml/ActivityFeed.qml
        qml/SnapshotCard.qml

        # Components
        qml/AppButton.qml
        qml/AppDialog.qml
        qml/AppIcon.qml
        qml/Avatar.qml
        qml/BusySpinner.qml
        qml/Brackets.qml
        qml/CalloutTag.qml
        qml/FpsChart.qml
        qml/SegmentMeter.qml
        qml/Card.qml
        qml/ControlTile.qml
        qml/EmptyState.qml
        qml/NavItem.qml
        qml/PageHeader.qml
        qml/Pill.qml
        qml/Radar.qml
        qml/RoundedImage.qml
        qml/SegmentedControl.qml
        qml/SettingRow.qml
        qml/StatTile.qml
        qml/StatusDot.qml
        qml/StatusLine.qml
        qml/ToastHost.qml
        qml/ToggleSwitch.qml
)
target_include_directories(appqt_DoorDarshanLive PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${OpenCV_INCLUDE_DIRS}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appqt_DoorDarshanLive PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appqt_DoorDarshanLive
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appqt_DoorDarshanLive PRIVATE
    Qt6::Quick
    Qt6::Network
    Qt6::Sql
    ${OpenCV_LIBS}
)
install(TARGETS appqt_DoorDarshanLive
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

find_package(PkgConfig REQUIRED)

pkg_check_modules(GST REQUIRED
        gstreamer-1.0
        gstreamer-video-1.0
        gstreamer-app-1.0
)

target_include_directories(appqt_DoorDarshanLive PRIVATE
        ${GST_INCLUDE_DIRS}
)

target_compile_options(appqt_DoorDarshanLive PRIVATE
        ${GST_CFLAGS_OTHER}
)

target_link_directories(appqt_DoorDarshanLive PRIVATE
        ${GST_LIBRARY_DIRS}
)

target_link_libraries(appqt_DoorDarshanLive PRIVATE
        ${GST_LIBRARIES}
)

file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/models/face_detection_yunet_2023mar.onnx"
     DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
 file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/models/face_recognition_sface_2021dec.onnx"
      DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")

option(DD_BUILD_TESTS "Build the Qt Test unit tests" ON)
if(DD_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
