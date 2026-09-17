#ifndef DISCOVERYSERVICE_H
#define DISCOVERYSERVICE_H

#include <QObject>
#include<QUdpSocket>
#include <QTimer>
class DiscoveryService:public QObject
{
    Q_OBJECT
public:
    explicit DiscoveryService(QObject* parent = nullptr);

    void start();
    void stop();
    void discover();
public slots:
    void processPendingDatagrams();
private:
    void broadcastDiscovery();


signals:
    void discoveryFinished();
private:
    QUdpSocket* m_socket;
    QTimer m_timer;

    int m_broadcastCount = 0;
};

#endif // DISCOVERYSERVICE_H
