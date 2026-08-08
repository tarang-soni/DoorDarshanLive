#include "videobridge.h"
#include <QDebug>
#include <QMutexLocker>


VideoBridge::VideoBridge(QObject *parent)
    : QObject(parent),
    m_pipeline(nullptr),
    m_appSink(nullptr)
{
    if (!gst_is_initialized())
    {
        gst_init(nullptr, nullptr);
        qDebug() << "GStreamer initialized";
    }
}

VideoBridge::~VideoBridge()
{
    stopListening();
}

void VideoBridge::startListening()
{
    if (m_pipeline)
        return;

    QString pipeline =
        "udpsrc port=5000 "
        "caps=\"application/x-rtp,media=video,clock-rate=90000,"
        "encoding-name=H264,payload=96\" ! "
        "rtpjitterbuffer latency=200 ! "
        "rtph264depay ! "
        "h264parse ! "
        "avdec_h264 ! "
        "videoconvert ! "
        "video/x-raw,format=RGBA ! "
        "appsink name=mysink "
        "emit-signals=true "
        "sync=false "
        "max-buffers=1 "
        "drop=true";

    GError *error = nullptr;

    m_pipeline = gst_parse_launch(
        pipeline.toUtf8().constData(),
        &error);

    if (error)
    {
        qCritical() << error->message;
        g_error_free(error);
        return;
    }

    m_appSink = GST_APP_SINK(
        gst_bin_get_by_name(
            GST_BIN(m_pipeline),
            "mysink"));

    if (!m_appSink)

    {
        qCritical() << "Couldn't find appsink";
        cleanupPipeline();
        return;
    }

    g_signal_connect(
        m_appSink,
        "new-sample",
        G_CALLBACK(VideoBridge::onNewSample),
        this);

    gst_element_set_state(
        m_pipeline,
        GST_STATE_PLAYING);

    qDebug() << "Pipeline started";
}

void VideoBridge::stopListening()
{
    if (!m_pipeline)
        return;

    gst_element_set_state(
        m_pipeline,
        GST_STATE_NULL);

    cleanupPipeline();
}

void VideoBridge::cleanupPipeline()
{
    if (m_appSink)
    {
        gst_object_unref(m_appSink);
        m_appSink = nullptr;
    }

    if (m_pipeline)
    {
        gst_object_unref(m_pipeline);
        m_pipeline = nullptr;
    }
}

GstFlowReturn VideoBridge::onNewSample(
    GstAppSink *sink,
    gpointer user_data)
{
    return static_cast<VideoBridge*>(user_data)
    ->processFrame(sink);
}


GstFlowReturn VideoBridge::processFrame(GstAppSink *sink)
{
    GstSample *sample = gst_app_sink_pull_sample(sink);

    if (!sample)
        return GST_FLOW_ERROR;

    GstBuffer *buffer = gst_sample_get_buffer(sample);

    GstMapInfo map;

    if (!gst_buffer_map(buffer, &map, GST_MAP_READ))
    {
        gst_sample_unref(sample);
        return GST_FLOW_ERROR;
    }

    GstCaps *caps = gst_sample_get_caps(sample);

    GstStructure *structure =
        gst_caps_get_structure(caps, 0);

    int width = 0;
    int height = 0;

    gst_structure_get_int(structure, "width", &width);
    gst_structure_get_int(structure, "height", &height);

    QImage image(
        map.data,
        width,
        height,
        QImage::Format_RGBA8888);

    // Make a deep copy because GStreamer owns map.data
    {
        QMutexLocker locker(&m_mutex);
        m_currentFrame = image.copy();
    }

    gst_buffer_unmap(buffer, &map);
    gst_sample_unref(sample);

    emit frameReady();

    return GST_FLOW_OK;
}

QImage VideoBridge::currentFrame() const
{
    QMutexLocker locker(&m_mutex);
    return m_currentFrame;
}