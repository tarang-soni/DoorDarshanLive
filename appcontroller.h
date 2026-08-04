#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "networkmanager.h"
#include "uimanager.h"
class AppController : public QObject
{
    Q_OBJECT
public:
    explicit AppController(QObject *parent = nullptr);

    inline UIManager& getUiManager(){return *m_uiManager;}
signals:

private:
    NetworkManager* m_networkManager;
    UIManager* m_uiManager;
};

#endif // APPCONTROLLER_H
