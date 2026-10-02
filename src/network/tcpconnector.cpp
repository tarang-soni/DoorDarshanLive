#include "network/tcpconnector.h"
#include<iostream>
TcpConnector::TcpConnector(QObject *parent,const QHostAddress &address, quint16 port)
    : QObject{parent},m_activeClient{nullptr}
{
    server = new QTcpServer(this);
    connect(server,&QTcpServer::newConnection,this,&TcpConnector::onNewConnection);

    if(!server->listen(address,port))
    {
        std::cerr<<"Server couldnt start"<<std::endl;
    }
    else{
        std::cout << "TCP Server started, Listening on dynamic port "
                  << server->serverPort() << "..." << std::endl;
    }
}

QString TcpConnector::GetMessageFromCommand(ClientResponse resp)
{
    switch (resp)
    {
    case ClientResponse::ConnectionSuccess:
        return QString("[Pi Response]: Connection Established Successfully!");

    case ClientResponse::StreamStarted:
        return QString("[Pi Response]: Streaming started on remote device.");

    case ClientResponse::StreamStopped:
        return QString("[Pi Response]: Streaming stopped.");

    case ClientResponse::ErrorDeviceBusy:
        return QString("[Pi Response Error]: Device is busy!");

    case ClientResponse::Pong:
        return QString("[Pi Response]: Pong received.");

    case ClientResponse::ConnectionEnded:
        return QString("[Pi Response]: Client requested connection end.");

    default:
        return QString("[Pi Response]: Unknown command byte received.");
    }
}

void TcpConnector::handleStates(const ClientResponse resp)
{
    switch(resp)
    {
    case ClientResponse::StreamStarted:
        emit streamApproved();
        break;
    case ClientResponse::StreamStopped:
        emit streamStopped();
    default:
        break;
    }
}

void TcpConnector::onNewConnection()
{
    m_activeClient = server->nextPendingConnection();
    qDebug()<<"new client connected!!!";
    m_activeClient->setSocketOption(QAbstractSocket::LowDelayOption, 1);
    connect(m_activeClient,&QTcpSocket::readyRead,this,&TcpConnector::onReadyRead);
    connect(m_activeClient ,&QTcpSocket::disconnected,this,&TcpConnector::onSocketDisconnected);
    emit connectedChanged(true);
}

void TcpConnector::onReadyRead()
{
    if (!m_activeClient)
        return;
    // TCP is a byte stream, so several one-byte responses can arrive in one read.
    const QByteArray data = m_activeClient->readAll();
    for (char byte : data)
    {
        ClientResponse resp = static_cast<ClientResponse>(static_cast<uint8_t>(byte));
        qDebug() << GetMessageFromCommand(resp);
        handleStates(resp);
    }
}

void TcpConnector::onSocketDisconnected()
{
    if (!m_activeClient)
        return;

    std::cout << "Client disconnected." << std::endl;
    m_activeClient->deleteLater();
    m_activeClient = nullptr;
    emit connectedChanged(false);
}

void TcpConnector::onCommandTransmitted(ServerCommand cmd)
{
    if(!m_activeClient)return;
    uint8_t rawByte = static_cast<uint8_t>(cmd);
    QByteArray data(reinterpret_cast<const char*>(&rawByte),1);
    m_activeClient->write(data);
    m_activeClient->flush();
}
void TcpConnector::disconnectClient()
{
    if (m_activeClient) {
        qDebug() << "Forcefully disconnecting client...";

        // Optional: If you have a disconnect command in Protocol.h, you can send it first
        // onCommandTransmitted(ServerCommand::EndConnection);

        m_activeClient->disconnectFromHost();
        // This will automatically trigger onSocketDisconnected() to clean up the pointer
    }
}