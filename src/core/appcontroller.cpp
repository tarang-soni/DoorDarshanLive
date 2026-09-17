#include "core/appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject{parent}
{
    m_networkManager = new NetworkManager(this);
    m_uiManager = new UIManager(this);
    m_videoBridge = new VideoBridge(this);

    connect(m_networkManager,&NetworkManager::piConnectedChanged,m_uiManager,&UIManager::setPiConnected);
    connect(m_uiManager,&UIManager::startStreamRequested,m_networkManager,&NetworkManager::startStream);
    connect(m_uiManager,&UIManager::stopStreamRequested,m_networkManager,&NetworkManager::stopStream);
    connect(m_networkManager,&NetworkManager::streamApproved,m_uiManager,&UIManager::isStreamingChanged);
    connect(m_networkManager,&NetworkManager::streamApproved,m_videoBridge,&VideoBridge::startListening,Qt::QueuedConnection);
    connect(m_networkManager,&NetworkManager::streamStopped,m_videoBridge,&VideoBridge::stopListening,Qt::QueuedConnection);
}
