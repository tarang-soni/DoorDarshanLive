#include "discoveryservice.h"
#include<QDebug>
#include <QNetworkDatagram>
#include "../core/utils.h"
DiscoveryService::DiscoveryService(QObject* parent):m_socket(nullptr)
{
    connect(&m_timer,&QTimer::timeout,this,&DiscoveryService::broadcastDiscovery);
}

void DiscoveryService::start()
{
    if(m_socket)return;
    m_socket = new QUdpSocket(this);
    if(!m_socket->bind(DISCOVERY_PORT,
                   QUdpSocket::ShareAddress |
                            QUdpSocket::ReuseAddressHint))
    {
        qWarning() << "Failed to bind discovery socket:"
                   << m_socket->errorString();
    }
    connect(m_socket,
            &QUdpSocket::readyRead,
            this,
            &DiscoveryService::processPendingDatagrams);

}

void DiscoveryService::stop()
{
    if(!m_socket) return;
    m_timer.stop();
    m_socket->close();
    m_socket->deleteLater();
    m_socket = nullptr;
}

void DiscoveryService::broadcastDiscovery()
{
    if (m_broadcastCount >= 3)
    {
        m_timer.stop();
        emit discoveryFinished();
        return;
    }

    QByteArray packet = "DD_DISCOVERY";

    qint64 bytes = m_socket->writeDatagram(packet,
                            QHostAddress::Broadcast,
                            DISCOVERY_PORT);
    if (bytes == -1)
    {
        qWarning() << "Broadcast failed:" << m_socket->errorString();
    }
    ++m_broadcastCount;
}

void DiscoveryService::discover()
{
    if (!m_socket)
        return;

    m_timer.stop();
    m_broadcastCount = 0;
    broadcastDiscovery();
    m_timer.start(300);


}

void DiscoveryService::processPendingDatagrams()
{
    while(m_socket->hasPendingDatagrams())
    {
        QNetworkDatagram datagram = m_socket->receiveDatagram();
        qDebug() << "Received from:"
                 << datagram.senderAddress().toString()
                 << ":" << datagram.senderPort();

        qDebug() << "Data:" << datagram.data();
    }
}