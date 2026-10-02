#include "core/appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject{parent}
{
    m_networkManager = new NetworkManager(this);
    m_uiManager = new UIManager(this);
    m_videoBridge = new VideoBridge(this);
    m_databaseManager = new DatabaseManager(this);
    m_databaseManager->initDatabase();
    m_snapshotManager = new SnapshotManager(m_databaseManager, this);

    connect(m_networkManager,&NetworkManager::piConnectedChanged,m_uiManager,&UIManager::setPiConnected);
    connect(m_uiManager,&UIManager::startStreamRequested,m_networkManager,&NetworkManager::startStream);
    connect(m_uiManager,&UIManager::stopStreamRequested,m_networkManager,&NetworkManager::stopStream);
    connect(m_uiManager,&UIManager::findDevicesRequested,m_networkManager,&NetworkManager::discoverDevices);
    connect(m_uiManager,&UIManager::piConnectionRequested,m_networkManager,&NetworkManager::connectToPi);

    // NEW: Connect the UI disconnect request to the NetworkManager
    connect(m_uiManager,&UIManager::piDisconnectRequested,m_networkManager,&NetworkManager::disconnectFromPi);

    connect(m_networkManager,&NetworkManager::streamApproved,m_uiManager,&UIManager::isStreamingChanged);
    connect(m_networkManager,&NetworkManager::streamApproved,m_videoBridge,&VideoBridge::startListening,Qt::QueuedConnection);
    connect(m_networkManager,&NetworkManager::streamStopped,m_videoBridge,&VideoBridge::stopListening,Qt::QueuedConnection);
    connect(m_networkManager,&NetworkManager::discoveryDeviceFound,m_uiManager,&UIManager::deviceFound);
    connect(m_networkManager,&NetworkManager::deviceDiscoveryStopped,m_uiManager,&UIManager::deviceDiscoveryStopped);
    connect(m_uiManager, &UIManager::cameraUiEnabledChanged, this, &AppController::evaluateStreamState);
    connect(m_uiManager, &UIManager::motionEnabledChanged, this, &AppController::evaluateStreamState);

    reloadAIIdentities();
}
SnapshotManager *AppController::snapshotManager() const
{
    return m_snapshotManager;
}

void AppController::takeManualSnapshot()
{
    if (!m_videoBridge || !m_snapshotManager) return;

    QImage currentFrame = m_videoBridge->currentFrame();

    // Grab the face fingerprint and name from the AI thread
    QByteArray liveEncoding = m_videoBridge->currentFaceEncoding();
    QString liveName = m_videoBridge->currentFaceName();

    bool isKnown = !liveName.isEmpty() && liveName != "Unknown" && liveName != "Visitor";
    int identityId = isKnown ? m_databaseManager->getIdentityIdByName(liveName) : -1;

    // Save with the AI data included
    m_snapshotManager->saveSnapshot(currentFrame, liveEncoding, isKnown, identityId);
}

void AppController::reloadAIIdentities()
{
    if (m_databaseManager && m_videoBridge) {
        m_videoBridge->refreshKnownFaces(m_databaseManager->getIdentitiesForAI());
    }
}


void AppController::evaluateStreamState()
{
    bool cameraOn = m_uiManager->cameraUiEnabled();
    bool motionOn = m_uiManager->motionEnabled();

    // 1. Tell the AI worker exactly how it should behave
    if (m_videoBridge) {
        m_videoBridge->setDetectionModes(cameraOn, motionOn);
    }

    // 2. Control the network stream
    bool needsStream = cameraOn || motionOn;

    if (m_networkManager) {
        if (needsStream) {
            m_networkManager->startStream();
        } else {
            m_networkManager->stopStream();
        }
    }
}