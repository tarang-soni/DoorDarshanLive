#include "networkmanager.h"

NetworkManager::NetworkManager(QObject *parent)
    : QObject{parent}
{
    m_tcpConnector = new TcpConnector(this,QHostAddress::Any,1234);//move the hardcoded values to a data header file so its easy to change. can be static class as well or global header
    connect(this,&NetworkManager::transmitCommand,m_tcpConnector,&TcpConnector::onCommandTransmitted);
    connect(m_tcpConnector,&TcpConnector::streamApproved,this,&NetworkManager::streamApproved);
    connect(m_tcpConnector,&TcpConnector::streamStopped,this,&NetworkManager::streamStopped);
}
