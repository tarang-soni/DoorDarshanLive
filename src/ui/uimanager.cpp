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
