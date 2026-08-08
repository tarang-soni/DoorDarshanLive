#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include "tcpconnector.h"
#include "Protocol.h"
class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr);

signals:
    void transmitCommand(ServerCommand cmd);
    void streamApproved();
    void streamStopped();
public slots:


private:
    TcpConnector* m_tcpConnector;
};

#endif // NETWORKMANAGER_H
