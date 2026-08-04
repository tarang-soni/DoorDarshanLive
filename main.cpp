#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "appcontroller.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    AppController m_appController;

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
