#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject{parent}
{
    m_networkManager = new NetworkManager(this);
    m_uiManager = new UIManager(this);
    m_videoBridge = new VideoBridge(this);

    connect(m_uiManager,&UIManager::transmitCommand,m_networkManager,&NetworkManager::transmitCommand);
    connect(m_networkManager,&NetworkManager::streamApproved,m_videoBridge,&VideoBridge::startListening,Qt::QueuedConnection);
    connect(m_networkManager,&NetworkManager::streamStopped,m_videoBridge,&VideoBridge::stopListening,Qt::QueuedConnection);
}
