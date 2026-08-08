#include "ui/uimanager.h"

UIManager::UIManager(QObject *parent)
    : QObject{parent}
{}

void UIManager::requestStartStream()
{
    transmitCommand(ServerCommand::StartStream);
}

void UIManager::requestStopStream()
{
    transmitCommand(ServerCommand::StopStream);
}

void UIManager::requestQuit()
{
    transmitCommand(ServerCommand::Quit);
}
