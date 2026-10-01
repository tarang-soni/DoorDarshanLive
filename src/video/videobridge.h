#ifndef VIDEOBRIDGE_H
#define VIDEOBRIDGE_H

#include <QObject>
#include <QImage>
#include <QMutex>
#include <QThread>
#include <QVariantList>
#include <QVariantMap>
#include <vector>

#include <gst/gst.h>
#include <gst/app/gstappsink.h>

#include "faceai.h"

class VideoBridge : public QObject
{
    Q_OBJECT

public:
    explicit VideoBridge(QObject *parent = nullptr);
    ~VideoBridge();
    QImage currentFrame() const;

    QByteArray currentFaceEncoding() const;
    QString currentFaceName() const;
    void refreshKnownFaces(const QVariantList &dbList);


public slots:
    void startListening();
    void stopListening();
    void setDetectionModes(bool continuous, bool motionGated); // <--- UPDATE THIS
signals:
    void frameReady();
    void streamStopped();
    void faceDetected(int x, int y, int w, int h, const QString &name);
    void faceLost();
    void motionAlertTriggered();
private:
    void cleanupPipeline();
    void setupAI();

    static GstFlowReturn onNewSample(GstAppSink *sink, gpointer user_data);
    GstFlowReturn processFrame(GstAppSink *sink);

private:
    GstElement *m_pipeline = nullptr;
    GstAppSink *m_appSink = nullptr;

    QImage m_currentFrame;
    mutable QMutex m_mutex;

    QThread m_aiThread;
    FaceDetectionWorker *m_aiWorker = nullptr;

    std::vector<FaceResult> m_lastDetectedFaces;
};

#endif // VIDEOBRIDGE_H