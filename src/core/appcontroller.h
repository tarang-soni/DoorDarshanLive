#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "network/networkmanager.h"
#include "ui/uimanager.h"
#include "video/videobridge.h"
class AppController : public QObject
{
    Q_OBJECT
public:
    explicit AppController(QObject *parent = nullptr);

    Q_PROPERTY(UIManager* uiManager READ uiManager CONSTANT)
    UIManager* uiManager() const { return m_uiManager; }
    Q_PROPERTY(VideoBridge* videoBridge READ videoBridge CONSTANT)
    VideoBridge* videoBridge() const { return m_videoBridge; }
    inline UIManager& getUiManager(){return *m_uiManager;}

private:
    NetworkManager* m_networkManager;
    UIManager* m_uiManager;
    VideoBridge* m_videoBridge;
};

#endif // APPCONTROLLER_H
