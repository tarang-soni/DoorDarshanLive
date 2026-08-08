#include "include/tcptestsocket.h"
#include<iostream>

TcpTestSocket::TcpTestSocket(QObject *parent)
    : QObject{parent}
{
    server = new QTcpServer(this);
    connect(server,&QTcpServer::newConnection,this,&TcpTestSocket::onNewConnection);

    if(!server->listen(QHostAddress::Any,1234))
    {
        std::cerr<<"Server couldnt start"<<std::endl;
    }
    else{
        std::cout<<"Server started, Listening on port 1234..."<<std::endl;
    }
}
void TcpTestSocket::onNewConnection()
{
    QTcpSocket* s = server->nextPendingConnection();
    qDebug()<<"new client connected!!!";

    connect(s,&QTcpSocket::readyRead,this,&TcpTestSocket::onReadyRead);
    connect(s,&QTcpSocket::disconnected,this,&TcpTestSocket::onSocketDisconnected);

    s->write("Hello from qt tcp server\n");
    s->flush();
}

void TcpTestSocket::onReadyRead()
{
    QTcpSocket* s = qobject_cast<QTcpSocket*>(sender());
    if(!s)return;
    QByteArray data = s->readAll();
    std::cout << "Received command: " << data.constData() << std::endl;

    // Echo back or process command logic here
    s->write("Command acknowledged\r\n");
}

void TcpTestSocket::onSocketDisconnected()
{
    QTcpSocket *clientSocket = qobject_cast<QTcpSocket*>(sender());
    if (!clientSocket) return;

    std::cout << "Client disconnected." << std::endl;
    clientSocket->deleteLater();
}
