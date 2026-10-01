#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "network/networkmanager.h"
#include "ui/uimanager.h"
#include "video/videobridge.h"
#include "databasemanager.h"
#include "video/snapshotmanager.h"
class AppController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(UIManager* uiManager READ uiManager CONSTANT)
    Q_PROPERTY(VideoBridge* videoBridge READ videoBridge CONSTANT)
    // ADD THIS:
    Q_PROPERTY(DatabaseManager* databaseManager READ databaseManager CONSTANT)
    Q_PROPERTY(SnapshotManager* snapshotManager READ snapshotManager CONSTANT)

public:
    explicit AppController(QObject *parent = nullptr);

    UIManager* uiManager() const { return m_uiManager; }
    VideoBridge* videoBridge() const { return m_videoBridge; }
    // ADD THIS:
    DatabaseManager* databaseManager() const { return m_databaseManager; }

    inline UIManager& getUiManager(){return *m_uiManager;}

    SnapshotManager *snapshotManager() const;
    Q_INVOKABLE void takeManualSnapshot();
    Q_INVOKABLE void reloadAIIdentities();

private slots:
    void evaluateStreamState();
private:
    NetworkManager* m_networkManager;
    UIManager* m_uiManager;
    VideoBridge* m_videoBridge;
    // ADD THIS:
    DatabaseManager* m_databaseManager;
    SnapshotManager *m_snapshotManager = nullptr;
};

#endif // APPCONTROLLER_H