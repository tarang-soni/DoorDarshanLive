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
        std::cout<<"Server started, Listening on port 1234..."<<std::endl;
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

}

void TcpConnector::onReadyRead()
{
    QTcpSocket* s = qobject_cast<QTcpSocket*>(sender());
    if(!s)return;
    QByteArray data = s->readAll();
    if (data.isEmpty()) return;
    uint8_t value = static_cast<uint8_t>(data.at(0));
    ClientResponse resp = static_cast<ClientResponse>(value);
    qDebug() << GetMessageFromCommand(resp);
    handleStates(resp);
}

void TcpConnector::onSocketDisconnected()
{
    QTcpSocket *clientSocket = qobject_cast<QTcpSocket*>(sender());
    if (!clientSocket) return;

    std::cout << "Client disconnected." << std::endl;
    clientSocket->deleteLater();
}

void TcpConnector::onCommandTransmitted(ServerCommand cmd)
{
    if(!m_activeClient)return;
    uint8_t rawByte = static_cast<uint8_t>(cmd);
    QByteArray data(reinterpret_cast<const char*>(&rawByte),1);
    m_activeClient->write(data);
    m_activeClient->flush();
}
