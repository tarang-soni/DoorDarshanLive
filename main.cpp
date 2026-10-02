#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "core/appcontroller.h"
#include "video/cameraimageprovider.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationVersion(QStringLiteral(DD_APP_VERSION));
    app.setWindowIcon(QIcon(QStringLiteral(":/qt/qml/qt_DoorDarshanLive/resources/images/app-icon.png")));

    QQmlApplicationEngine engine;
    AppController m_appController;
    engine.rootContext()->setContextProperty("app",&m_appController);
    engine.addImageProvider(
        "camera",
        new CameraImageProvider(
            m_appController.videoBridge()));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("qt_DoorDarshanLive", "Main");

    return QCoreApplication::exec();
}
