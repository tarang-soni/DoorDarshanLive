#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "core/appcontroller.h"
#include "video/cameraimageprovider.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    AppController m_appController;
    engine.rootContext()->setContextProperty(
        "videoBridge",
        m_appController.videoBridge());

    engine.rootContext()->setContextProperty("app",&m_appController);

    engine.addImageProvider(
        "camera",
        new CameraImageProvider(
            m_appController.videoBridge()));
    engine.rootContext()->setContextProperty("uiManager",&m_appController.getUiManager());
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("qt_DoorDarshanLive", "Main");



    return QCoreApplication::exec();
}
