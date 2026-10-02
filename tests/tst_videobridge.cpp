#include <QtTest>
#include "video/cameraimageprovider.h"
#include "video/videobridge.h"

// Plays the Pi's camera: streams RTP/JPEG test frames to UDP 5000 on localhost.
// RTP/JPEG only carries 4:2:0 and 4:2:2 JPEGs, so the format must be pinned or
// rtpjpegpay drops every frame.
class FakeCamera
{
public:
    FakeCamera(int width, int height)
    {
        const QByteArray description = QString(
            "videotestsrc is-live=true pattern=ball ! "
            "video/x-raw,format=I420,width=%1,height=%2,framerate=15/1 ! "
            "jpegenc ! rtpjpegpay ! "
            "udpsink host=127.0.0.1 port=5000").arg(width).arg(height).toUtf8();

        GError *error = nullptr;
        m_pipeline = gst_parse_launch(description.constData(), &error);
        if (error) {
            qWarning() << error->message;
            g_error_free(error);
        }
    }

    ~FakeCamera()
    {
        if (m_pipeline) {
            gst_element_set_state(m_pipeline, GST_STATE_NULL);
            gst_object_unref(m_pipeline);
        }
    }

    bool start()
    {
        return m_pipeline
            && gst_element_set_state(m_pipeline, GST_STATE_PLAYING) != GST_STATE_CHANGE_FAILURE;
    }

private:
    GstElement *m_pipeline = nullptr;
};

class TestVideoBridge : public QObject
{
    Q_OBJECT

private slots:
    void noFrameBeforeStreaming();
    void receivesFramesFromRtpStream();
    void imageProviderServesCurrentFrame();
    void stopListeningEmitsStoppedAndFaceLost();
    void stopWithoutStartIsSilent();
    void canRestartAfterStop();
};

void TestVideoBridge::noFrameBeforeStreaming()
{
    VideoBridge bridge;

    QVERIFY(bridge.currentFrame().isNull());
    QVERIFY(bridge.currentFaceEncoding().isEmpty());
    QVERIFY(bridge.currentFaceName().isEmpty());
}

void TestVideoBridge::receivesFramesFromRtpStream()
{
    VideoBridge bridge;
    QSignalSpy frames(&bridge, &VideoBridge::frameReady);
    bridge.startListening();

    FakeCamera camera(320, 240);
    QVERIFY(camera.start());

    QTRY_VERIFY_WITH_TIMEOUT(frames.count() >= 3, 10000);
    const QImage frame = bridge.currentFrame();
    QCOMPARE(frame.size(), QSize(320, 240));
    QCOMPARE(frame.format(), QImage::Format_RGBA8888);
}

void TestVideoBridge::imageProviderServesCurrentFrame()
{
    VideoBridge bridge;
    QSignalSpy frames(&bridge, &VideoBridge::frameReady);
    bridge.startListening();
    FakeCamera camera(160, 120);
    QVERIFY(camera.start());
    QTRY_VERIFY_WITH_TIMEOUT(frames.count() >= 1, 10000);

    CameraImageProvider provider(&bridge);
    QSize size;
    const QImage image = provider.requestImage("live", &size, QSize());

    QCOMPARE(image.size(), QSize(160, 120));
    QCOMPARE(size, QSize(160, 120));
}

void TestVideoBridge::stopListeningEmitsStoppedAndFaceLost()
{
    VideoBridge bridge;
    bridge.startListening();
    QSignalSpy stopped(&bridge, &VideoBridge::streamStopped);
    QSignalSpy lost(&bridge, &VideoBridge::faceLost);

    bridge.stopListening();

    QCOMPARE(stopped.count(), 1);
    QVERIFY(lost.count() >= 1);
}

void TestVideoBridge::stopWithoutStartIsSilent()
{
    VideoBridge bridge;
    QSignalSpy stopped(&bridge, &VideoBridge::streamStopped);

    bridge.stopListening();

    QCOMPARE(stopped.count(), 0);
}

void TestVideoBridge::canRestartAfterStop()
{
    VideoBridge bridge;
    bridge.startListening();
    bridge.stopListening();

    QSignalSpy frames(&bridge, &VideoBridge::frameReady);
    bridge.startListening();
    FakeCamera camera(320, 240);
    QVERIFY(camera.start());

    QTRY_VERIFY_WITH_TIMEOUT(frames.count() >= 1, 10000);
}

QTEST_MAIN(TestVideoBridge)
#include "tst_videobridge.moc"
