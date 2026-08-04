#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject{parent}
{
    m_networkManager = new NetworkManager(this);
    m_uiManager = new UIManager(this);

    connect(m_uiManager,&UIManager::transmitCommand,m_networkManager,&NetworkManager::transmitCommand);
}
