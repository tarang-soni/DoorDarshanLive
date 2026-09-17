#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include "tcpconnector.h"
#include "discoveryservice.h"
class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr);

signals:
    void transmitCommand(ServerCommand cmd);
    void streamApproved();
    void streamStopped();

    void piConnectedChanged(bool enabled);
public slots:
    void startStream();
    void stopStream();


private:
    TcpConnector* m_tcpConnector;
    DiscoveryService* m_discoveryService;
};

#endif // NETWORKMANAGER_H
