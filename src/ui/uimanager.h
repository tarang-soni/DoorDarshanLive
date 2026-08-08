#ifndef UIMANAGER_H
#define UIMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include "network/Protocol.h"

class UIManager : public QObject
{
    Q_OBJECT
public:
    explicit UIManager(QObject *parent = nullptr);
    Q_INVOKABLE void requestStartStream();
    Q_INVOKABLE void requestStopStream();
    Q_INVOKABLE void requestQuit();
public slots:
signals:
    void transmitCommand(ServerCommand cmd);
};

#endif // UIMANAGER_H
