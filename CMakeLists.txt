cmake_minimum_required(VERSION 3.16)

project(qt_DoorDarshanLive VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Network)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appqt_DoorDarshanLive
    main.cpp
)

qt_add_qml_module(appqt_DoorDarshanLive
    URI qt_DoorDarshanLive
    QML_FILES
        Main.qml
        SOURCES main.cpp
        SOURCES
        SOURCES appcontroller.h appcontroller.cpp
        SOURCES networkmanager.h networkmanager.cpp
        SOURCES uimanager.h uimanager.cpp
        SOURCES tcpconnector.h tcpconnector.cpp
        SOURCES Utils.h
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

target_link_libraries(appqt_DoorDarshanLive
    PRIVATE Qt6::Quick
)

install(TARGETS appqt_DoorDarshanLive
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
