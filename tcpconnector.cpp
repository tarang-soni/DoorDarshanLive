#include "tcpconnector.h"
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

QString TcpConnector::GetMessageFromCommand(const ClientResponse &resp)
{
    switch (resp) {
    case ClientResponse::ConnectionSuccess:
        return "[Pi Response]: Connection Established Successfully!";
    case ClientResponse::StreamStarted:
        return "[Pi Response]: Streaming started on remote device.";
    case ClientResponse::StreamStopped:
        return "[Pi Response]: Streaming stopped.";
    case ClientResponse::ErrorDeviceBusy:
        return "[Pi Response Error]: Device is busy!";
    case ClientResponse::Pong:
        return "[Pi Response]: Pong received.";
    case ClientResponse::ConnectionEnded:
        return "[Pi Response]: Client requested connection end.";
    default:
        return "[Pi Response]: Unknown command byte received.";
    }
}

void TcpConnector::onNewConnection()
{
    m_activeClient = server->nextPendingConnection();
    qDebug()<<"new client connected!!!";

    connect(m_activeClient,&QTcpSocket::readyRead,this,&TcpConnector::onReadyRead);
    connect(m_activeClient ,&QTcpSocket::disconnected,this,&TcpConnector::onSocketDisconnected);

    // s->write("Hello from qt tcp server\n");
    // s->flush();
}

void TcpConnector::onReadyRead()
{
    QTcpSocket* s = qobject_cast<QTcpSocket*>(sender());
    if(!s)return;
    QByteArray data = s->readAll();
    if (data.isEmpty()) return;
    ClientResponse resp = static_cast<ClientResponse>(data[0]);
    QString str = GetMessageFromCommand(resp);
    std::cout << "Received command: " << str.toStdString() << std::endl;
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
