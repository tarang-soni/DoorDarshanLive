#ifndef TCPTESTSOCKET_H
#define TCPTESTSOCKET_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QAbstractSocket>
class TcpTestSocket : public QObject
{
    Q_OBJECT
public:
    explicit TcpTestSocket(QObject *parent = nullptr);

signals:

public slots:
    void onNewConnection();
    void onReadyRead();
    void onSocketDisconnected();

private:
    QTcpServer* server;
};

#endif // TCPTESTSOCKET_H
