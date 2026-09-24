#include "discoveryservice.h"
#include<QDebug>
#include <QNetworkDatagram>
#include "../core/utils.h"
DiscoveryService::DiscoveryService(QObject* parent):m_socket(nullptr)
{
    connect(&m_timer,&QTimer::timeout,this,&DiscoveryService::broadcastDiscovery);
    start();
}

void DiscoveryService::start()
{
    if(m_socket)return;
    m_socket = new QUdpSocket(this);
    if(!m_socket->bind(QHostAddress::AnyIPv4,0))
    {
        qWarning() << "Failed to bind discovery socket:"
                   << m_socket->errorString();
    }
    connect(m_socket,
            &QUdpSocket::readyRead,
            this,
            &DiscoveryService::processPendingDatagrams);

}

// void DiscoveryService::stop()
// {
//     if(!m_socket) return;
//     m_timer.stop();
//     m_socket->close();
//     m_socket->deleteLater();
//     m_socket = nullptr;
// }
void DiscoveryService::discover()
{
    if (!m_socket)
        return;
    m_discoveredDevices.clear();
    m_timer.stop();
    m_broadcastCount = 0;
    broadcastDiscovery();
    m_timer.start(3000);


}

void DiscoveryService::sendCommandToDevice(const QByteArray &command,const QHostAddress& ip)
{
    m_socket->writeDatagram(command,ip,DISCOVERY_PORT);
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
    qDebug()<<"Packet Sent:"<<packet;
    ++m_broadcastCount;
}



void DiscoveryService::processPendingDatagrams()
{
    while(m_socket->hasPendingDatagrams())
    {
        QNetworkDatagram datagram = m_socket->receiveDatagram();

        QString data = QString::fromUtf8(datagram.data());

        if(data.startsWith("DD_REPLY"))
        {
            QHostAddress sender = datagram.senderAddress();
            if(sender.protocol()==QAbstractSocket::IPv4Protocol)
            {
                sender = QHostAddress(sender.toIPv4Address());
                QString ip = sender.toString();
                if(!m_discoveredDevices.contains(ip))
                {
                    m_discoveredDevices.insert(ip);
                    emit deviceFound(ip);
                }
            }

        }

    }
}