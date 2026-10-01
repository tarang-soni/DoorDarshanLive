#include "ui/uimanager.h"

UIManager::UIManager(QObject *parent)
    : QObject{parent}
{}

void UIManager::requestStartStream()
{
    startStreamRequested();
}

void UIManager::requestStopStream()
{
    stopStreamRequested();
}

void UIManager::requestQuit()
{
    qDebug()<<"Quit not implemented";
}

void UIManager::findDevices()
{
    emit findDevicesRequested();
}

void UIManager::connectToPi(const QString &ip)
{
    setConnectedIp(ip);
    emit piConnectionRequested(ip);
}



bool UIManager::piConnected() const
{
    return m_piConnected;
}

void UIManager::setPiConnected(bool newPiConnected)
{
    if (m_piConnected == newPiConnected)
        return;
    m_piConnected = newPiConnected;
    emit piConnectedChanged();
}

bool UIManager::isStreaming() const
{
    return m_isStreaming;
}

void UIManager::setIsStreaming(bool newIsStreaming)
{
    if (m_isStreaming == newIsStreaming)
        return;
    m_isStreaming = newIsStreaming;
    emit isStreamingChanged();
}

QString UIManager::connectedIp() const
{
    return m_connectedIp;
}

void UIManager::setConnectedIp(const QString &newConnectedIp)
{
    if (m_connectedIp == newConnectedIp)
        return;
    m_connectedIp = newConnectedIp;
    emit connectedIpChanged();
}
void UIManager::setCameraUiEnabled(bool enabled)
{
    if (m_cameraUiEnabled == enabled) return;
    m_cameraUiEnabled = enabled;
    emit cameraUiEnabledChanged();
}

void UIManager::setMotionEnabled(bool enabled)
{
    if (m_motionEnabled == enabled) return;
    m_motionEnabled = enabled;
    emit motionEnabledChanged();
}