#include "network/networkmanager.h"

NetworkManager::NetworkManager(QObject *parent)
    : QObject{parent}
{
    m_tcpConnector = new TcpConnector(this,QHostAddress::Any,0);//move the hardcoded values to a data header file so its easy to change. can be static class as well or global header
    m_discoveryService = new DiscoveryService(this);
    connect(this,&NetworkManager::transmitCommand,m_tcpConnector,&TcpConnector::onCommandTransmitted);
    connect(m_tcpConnector,&TcpConnector::streamApproved,this,&NetworkManager::streamApproved);
    connect(m_tcpConnector,&TcpConnector::streamStopped,this,&NetworkManager::streamStopped);
    connect(m_tcpConnector,&TcpConnector::connectedChanged,this,&NetworkManager::piConnectedChanged);
    connect(m_discoveryService,&DiscoveryService::deviceFound,this,&NetworkManager::discoveryDeviceFound);
    connect(m_discoveryService,&DiscoveryService::discoveryFinished,this,&NetworkManager::deviceDiscoveryStopped);
}

void NetworkManager::connectToPi(const QString &ip)
{
    qint16 tcpPort = m_tcpConnector->getServerPort();
    QByteArray packet = "DD_START_TCP:"+QByteArray::number( tcpPort);
    m_discoveryService->sendCommandToDevice(packet,QHostAddress(ip));
}
void NetworkManager::startStream()
{
    qDebug()<<"Starting stream...";
    emit transmitCommand(ServerCommand::StartStream);
}

void NetworkManager::stopStream()
{
    emit transmitCommand(ServerCommand::StopStream);
}

void NetworkManager::discoverDevices()
{
    m_discoveryService->discover();
}
