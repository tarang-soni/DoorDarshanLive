#ifndef VIDEOBRIDGE_H
#define VIDEOBRIDGE_H

#include <QObject>
#include <QImage>

#include <gst/gst.h>
#include <gst/app/gstappsink.h>
#include <QMutex>
class VideoBridge : public QObject
{
    Q_OBJECT

public:
    explicit VideoBridge(QObject *parent = nullptr);
    ~VideoBridge();
    QImage currentFrame() const;


public slots:
    void startListening();
    void stopListening();

signals:
    void frameReady();

private:
    void cleanupPipeline();

    static GstFlowReturn onNewSample(
        GstAppSink *sink,
        gpointer user_data);

    GstFlowReturn processFrame(
        GstAppSink *sink);

private:
    GstElement *m_pipeline;
    GstAppSink *m_appSink;

    QImage m_currentFrame;
    mutable QMutex m_mutex;
};

#endif