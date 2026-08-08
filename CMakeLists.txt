cmake_minimum_required(VERSION 3.16)

project(qt_DoorDarshanLive VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Network)

qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(appqt_DoorDarshanLive
    main.cpp
)

qt_add_qml_module(appqt_DoorDarshanLive
    URI qt_DoorDarshanLive

    QML_FILES
        Main.qml

    SOURCES
        src/core/appcontroller.h
        src/core/appcontroller.cpp

        src/network/networkmanager.h
        src/network/networkmanager.cpp
        src/network/tcpconnector.h
        src/network/tcpconnector.cpp
        src/network/Protocol.h

        src/ui/uimanager.h
        src/ui/uimanager.cpp

        src/video/videobridge.h
        src/video/videobridge.cpp
        src/video/cameraimageprovider.h
        src/video/cameraimageprovider.cpp
)
target_include_directories(appqt_DoorDarshanLive PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
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
