#ifndef TCPCONNECTOR_H
#define TCPCONNECTOR_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QAbstractSocket>
#include "Protocol.h"
class TcpConnector : public QObject
{
    Q_OBJECT
public:
    explicit TcpConnector(QObject *parent = nullptr,const QHostAddress &address = QHostAddress::Any, quint16 port = 0);

private:
    QString GetMessageFromCommand(const ClientResponse resp);
    void handleStates(const ClientResponse resp);
public slots:
    void onNewConnection();
    void onReadyRead();
    void onSocketDisconnected();
    void onCommandTransmitted(ServerCommand cmd);

signals:
    void streamApproved();
    void streamStopped();

private:
    QTcpServer* server;
    QTcpSocket* m_activeClient;
};

#endif // TCPCONNECTOR_H
