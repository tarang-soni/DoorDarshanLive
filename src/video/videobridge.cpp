#include "video/videobridge.h"
#include <QDebug>
#include <QMutexLocker>
#include <QCoreApplication>

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

    setupAI();
}

VideoBridge::~VideoBridge()
{
    m_aiThread.quit();
    m_aiThread.wait();
    stopListening();
}

void VideoBridge::setupAI()
{
    QString yunetPath = QCoreApplication::applicationDirPath() + "/face_detection_yunet_2023mar.onnx";
    QString sfacePath = QCoreApplication::applicationDirPath() + "/face_recognition_sface_2021dec.onnx";

    m_aiWorker = new FaceDetectionWorker(yunetPath.toStdString(), sfacePath.toStdString());
    m_aiWorker->moveToThread(&m_aiThread);

    connect(&m_aiThread, &QThread::finished, m_aiWorker, &QObject::deleteLater);

    connect(m_aiWorker, &FaceDetectionWorker::facesDetected, this, [this](const std::vector<FaceResult>& faces) {
        QMutexLocker locker(&m_mutex);
        m_lastDetectedFaces = faces;
    });
    connect(m_aiWorker, &FaceDetectionWorker::faceAlertTriggered, this, &VideoBridge::motionAlertTriggered);
    m_aiThread.start();
    qDebug() << "AI Thread started with YuNet & SFace models.";
}

void VideoBridge::startListening()
{
    if (m_pipeline) return;

    QString pipeline =
        "udpsrc port=5000 "
        "caps=\"application/x-rtp,media=video,clock-rate=90000,"
        "encoding-name=JPEG,payload=26\" ! "
        "rtpjitterbuffer latency=100 ! "
        "rtpjpegdepay ! "
        "jpegdec ! "
        "videoconvert ! "
        "video/x-raw,format=RGBA ! "
        "appsink name=mysink "
        "emit-signals=true "
        "sync=false "
        "max-buffers=1 "
        "drop=true";

    GError *error = nullptr;
    m_pipeline = gst_parse_launch(pipeline.toUtf8().constData(), &error);

    if (error) {
        qCritical() << error->message;
        g_error_free(error);
        return;
    }

    m_appSink = GST_APP_SINK(gst_bin_get_by_name(GST_BIN(m_pipeline), "mysink"));
    if (!m_appSink) {
        qCritical() << "Couldn't find appsink";
        cleanupPipeline();
        return;
    }

    g_signal_connect(m_appSink, "new-sample", G_CALLBACK(VideoBridge::onNewSample), this);
    gst_element_set_state(m_pipeline, GST_STATE_PLAYING);
    qDebug() << "Pipeline started";
}

void VideoBridge::stopListening()
{
    if (!m_pipeline) return;

    gst_element_set_state(m_pipeline, GST_STATE_NULL);
    cleanupPipeline();

    emit streamStopped();
    emit faceLost();
}
void VideoBridge::setDetectionModes(bool continuous, bool motionGated)
{
    if (m_aiWorker) {
        QMetaObject::invokeMethod(m_aiWorker, "setDetectionModes",
                                  Qt::QueuedConnection,
                                  Q_ARG(bool, continuous),
                                  Q_ARG(bool, motionGated));
    }
}

void VideoBridge::cleanupPipeline()
{
    if (m_appSink) {
        gst_object_unref(m_appSink);
        m_appSink = nullptr;
    }
    if (m_pipeline) {
        gst_object_unref(m_pipeline);
        m_pipeline = nullptr;
    }
}

GstFlowReturn VideoBridge::onNewSample(GstAppSink *sink, gpointer user_data)
{
    return static_cast<VideoBridge*>(user_data)->processFrame(sink);
}

GstFlowReturn VideoBridge::processFrame(GstAppSink *sink)
{
    GstSample *sample = gst_app_sink_pull_sample(sink);
    if (!sample) return GST_FLOW_ERROR;

    GstBuffer *buffer = gst_sample_get_buffer(sample);
    GstMapInfo map;

    if (!gst_buffer_map(buffer, &map, GST_MAP_READ)) {
        gst_sample_unref(sample);
        return GST_FLOW_ERROR;
    }

    GstCaps *caps = gst_sample_get_caps(sample);
    GstStructure *structure = gst_caps_get_structure(caps, 0);

    int width = 0;
    int height = 0;
    gst_structure_get_int(structure, "width", &width);
    gst_structure_get_int(structure, "height", &height);

    QImage image(map.data, width, height, QImage::Format_RGBA8888);

    if (m_aiWorker && !m_aiWorker->isBusy()) {
        QMetaObject::invokeMethod(m_aiWorker, "processFrame",
                                  Qt::QueuedConnection,
                                  Q_ARG(QImage, image.copy()));
    }

    {
        QMutexLocker locker(&m_mutex);
        m_currentFrame = image.copy();
    }

    if (!m_lastDetectedFaces.empty()) {
        const auto& face = m_lastDetectedFaces.front();
        QString detectedName = QString::fromStdString(face.name);
        if (detectedName.trimmed().isEmpty() || detectedName == "Visitor") {
            detectedName = "Unknown";
        }
        emit faceDetected(face.box.x(), face.box.y(), face.box.width(), face.box.height(), detectedName);
    } else {
        emit faceLost();
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

QByteArray VideoBridge::currentFaceEncoding() const
{
    QMutexLocker locker(&m_mutex);
    if (!m_lastDetectedFaces.empty() && !m_lastDetectedFaces.front().feature.empty()) {
        cv::Mat f = m_lastDetectedFaces.front().feature;
        return QByteArray(reinterpret_cast<const char*>(f.data), f.total() * f.elemSize());
    }
    return QByteArray();
}

QString VideoBridge::currentFaceName() const
{
    QMutexLocker locker(&m_mutex);
    if (!m_lastDetectedFaces.empty()) {
        QString name = QString::fromStdString(m_lastDetectedFaces.front().name);
        if (name != "Visitor" && name != "Unknown" && !name.trimmed().isEmpty()) {
            return name;
        }
    }
    return QString();
}

void VideoBridge::refreshKnownFaces(const QVariantList &dbList)
{
    std::vector<KnownIdentity> identities;
    for (const QVariant& v : dbList) {
        QVariantMap map = v.toMap();
        QByteArray arr = map["encoding"].toByteArray();
        if (arr.size() == 128 * sizeof(float)) {
            cv::Mat feature(1, 128, CV_32FC1);
            memcpy(feature.data, arr.constData(), arr.size());
            identities.push_back({map["name"].toString().toStdString(), feature.clone()});
        }
    }

    if (m_aiWorker) {
        QMetaObject::invokeMethod(m_aiWorker, "updateIdentities",
                                  Qt::QueuedConnection,
                                  Q_ARG(std::vector<KnownIdentity>, identities));
    }
}

