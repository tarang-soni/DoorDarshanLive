find_package(Qt6 REQUIRED COMPONENTS Test)

# The app target compiles its sources directly, so the tests build the same
# sources (minus main.cpp) into a static library they can link against.
add_library(dd_core STATIC
    ${PROJECT_SOURCE_DIR}/src/core/appcontroller.h
    ${PROJECT_SOURCE_DIR}/src/core/appcontroller.cpp
    ${PROJECT_SOURCE_DIR}/src/core/databasemanager.h
    ${PROJECT_SOURCE_DIR}/src/core/databasemanager.cpp
    ${PROJECT_SOURCE_DIR}/src/core/utils.h

    ${PROJECT_SOURCE_DIR}/src/network/Protocol.h
    ${PROJECT_SOURCE_DIR}/src/network/discoveryservice.h
    ${PROJECT_SOURCE_DIR}/src/network/discoveryservice.cpp
    ${PROJECT_SOURCE_DIR}/src/network/networkmanager.h
    ${PROJECT_SOURCE_DIR}/src/network/networkmanager.cpp
    ${PROJECT_SOURCE_DIR}/src/network/tcpconnector.h
    ${PROJECT_SOURCE_DIR}/src/network/tcpconnector.cpp

    ${PROJECT_SOURCE_DIR}/src/ui/uimanager.h
    ${PROJECT_SOURCE_DIR}/src/ui/uimanager.cpp

    ${PROJECT_SOURCE_DIR}/src/video/faceai.h
    ${PROJECT_SOURCE_DIR}/src/video/videobridge.h
    ${PROJECT_SOURCE_DIR}/src/video/videobridge.cpp
    ${PROJECT_SOURCE_DIR}/src/video/cameraimageprovider.h
    ${PROJECT_SOURCE_DIR}/src/video/cameraimageprovider.cpp
    ${PROJECT_SOURCE_DIR}/src/video/snapshotmanager.h
    ${PROJECT_SOURCE_DIR}/src/video/snapshotmanager.cpp
)
target_include_directories(dd_core PUBLIC
    ${PROJECT_SOURCE_DIR}/src
    ${OpenCV_INCLUDE_DIRS}
    ${GST_INCLUDE_DIRS}
)
target_compile_options(dd_core PUBLIC ${GST_CFLAGS_OTHER})
target_link_directories(dd_core PUBLIC ${GST_LIBRARY_DIRS})
target_link_libraries(dd_core PUBLIC
    Qt6::Quick
    Qt6::Network
    Qt6::Sql
    ${OpenCV_LIBS}
    ${GST_LIBRARIES}
)

# VideoBridge loads the face models from the executable's directory.
file(COPY
    ${PROJECT_SOURCE_DIR}/models/face_detection_yunet_2023mar.onnx
    ${PROJECT_SOURCE_DIR}/models/face_recognition_sface_2021dec.onnx
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
)

function(dd_add_test name)
    qt_add_executable(${name} ${name}.cpp)
    target_link_libraries(${name} PRIVATE dd_core Qt6::Test)
    target_compile_definitions(${name} PRIVATE
        DD_MODELS_DIR="${PROJECT_SOURCE_DIR}/models"
    )
    set_target_properties(${name} PROPERTIES
        MACOSX_BUNDLE FALSE
        WIN32_EXECUTABLE FALSE
    )
    add_test(NAME ${name} COMMAND ${name})
endfunction()

dd_add_test(tst_uimanager)
dd_add_test(tst_databasemanager)
dd_add_test(tst_snapshotmanager)
dd_add_test(tst_tcpconnector)
dd_add_test(tst_networkmanager)
dd_add_test(tst_facedetector)
dd_add_test(tst_videobridge)
dd_add_test(tst_appcontroller)

# These bind fixed ports (UDP 40000 for discovery, UDP 5000 for video).
set_tests_properties(tst_networkmanager PROPERTIES RESOURCE_LOCK udp_40000)
set_tests_properties(tst_videobridge PROPERTIES RESOURCE_LOCK udp_5000)
set_tests_properties(tst_appcontroller PROPERTIES RESOURCE_LOCK "udp_40000;udp_5000")
