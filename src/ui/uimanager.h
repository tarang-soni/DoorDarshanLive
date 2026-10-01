#ifndef UIMANAGER_H
#define UIMANAGER_H

#include <QObject>
#include <QQmlEngine>

class UIManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool piConnected READ piConnected WRITE setPiConnected NOTIFY piConnectedChanged FINAL)
    Q_PROPERTY(bool isStreaming READ isStreaming WRITE setIsStreaming NOTIFY isStreamingChanged FINAL)
    Q_PROPERTY(QString connectedIp READ connectedIp WRITE setConnectedIp NOTIFY connectedIpChanged)

    // NEW: Proper placement for UI state toggles
    Q_PROPERTY(bool cameraUiEnabled READ cameraUiEnabled WRITE setCameraUiEnabled NOTIFY cameraUiEnabledChanged)
    Q_PROPERTY(bool motionEnabled READ motionEnabled WRITE setMotionEnabled NOTIFY motionEnabledChanged)

public:
    explicit UIManager(QObject *parent = nullptr);
    Q_INVOKABLE void requestStartStream();
    Q_INVOKABLE void requestStopStream();
    Q_INVOKABLE void requestQuit();
    Q_INVOKABLE void findDevices();
    Q_INVOKABLE void connectToPi(const QString &ip);

    bool piConnected() const;
    bool isStreaming() const;
    void setIsStreaming(bool newIsStreaming);

    QString connectedIp() const;
    void setConnectedIp(const QString &newConnectedIp);

    bool cameraUiEnabled() const { return m_cameraUiEnabled; }
    void setCameraUiEnabled(bool enabled);

    bool motionEnabled() const { return m_motionEnabled; }
    void setMotionEnabled(bool enabled);

public slots:
    void setPiConnected(bool newPiConnected);

signals:
    void startStreamRequested();
    void stopStreamRequested();
    void piConnectedChanged();
    void isStreamingChanged();
    void findDevicesRequested();
    void deviceFound(const QString& ip);
    void deviceDiscoveryStopped();
    void piConnectionRequested(const QString &ip);
    void connectedIpChanged();

    // Signals for the new toggles
    void cameraUiEnabledChanged();
    void motionEnabledChanged();

private:
    bool m_piConnected = false;
    bool m_isStreaming = false;
    QString m_connectedIp;

    bool m_cameraUiEnabled = false;
    bool m_motionEnabled = false;
};

#endif // UIMANAGER_H