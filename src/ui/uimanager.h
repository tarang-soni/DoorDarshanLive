    #ifndef UIMANAGER_H
    #define UIMANAGER_H

    #include <QObject>
    #include <QQmlEngine>

    class UIManager : public QObject
    {
        Q_OBJECT
    public:
        explicit UIManager(QObject *parent = nullptr);
        Q_INVOKABLE void requestStartStream();
        Q_INVOKABLE void requestStopStream();
        Q_INVOKABLE void requestQuit();

        Q_PROPERTY(bool piConnected READ piConnected WRITE setPiConnected NOTIFY piConnectedChanged FINAL)
        Q_PROPERTY(bool isStreaming READ isStreaming WRITE setIsStreaming NOTIFY isStreamingChanged FINAL)
        bool piConnected() const;


        bool isStreaming() const;
        void setIsStreaming(bool newIsStreaming);

    public slots:
        void setPiConnected(bool newPiConnected);

    signals:
        void startStreamRequested();
        void stopStreamRequested();
        void piConnectedChanged();

        void isStreamingChanged();

    private:

        bool m_piConnected;
        bool m_isStreaming;
    };

    #endif // UIMANAGER_H
