#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "networkmanager.h"
#include "uimanager.h"
#include "videobridge.h"
class AppController : public QObject
{
    Q_OBJECT
public:
    explicit AppController(QObject *parent = nullptr);

    inline UIManager& getUiManager(){return *m_uiManager;}
    VideoBridge* videoBridge() const
    {
        return m_videoBridge;
    }
signals:

private:
    NetworkManager* m_networkManager;
    UIManager* m_uiManager;
    VideoBridge* m_videoBridge;
};

#endif // APPCONTROLLER_H
