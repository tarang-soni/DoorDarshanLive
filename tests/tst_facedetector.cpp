#include <QtTest>
#include <QImage>
#include "video/faceai.h"

namespace {

const std::string kYunet = DD_MODELS_DIR "/face_detection_yunet_2023mar.onnx";
const std::string kSface = DD_MODELS_DIR "/face_recognition_sface_2021dec.onnx";

QImage blankFrame(QColor color = Qt::gray)
{
    QImage frame(640, 480, QImage::Format_RGBA8888);
    frame.fill(color);
    return frame;
}

}

class TestFaceDetector : public QObject
{
    Q_OBJECT

private slots:
    void blankFrameHasNoFaces();
    void nullImageReturnsNothing();
    void skipsAiWhenBothModesOff();
    void alertFiresOnceAfterThirtyFaceFrames();
    void alertCountResetsWhenFaceLost();
    void workerEmitsResultsAndReleasesBusyFlag();
};

void TestFaceDetector::blankFrameHasNoFaces()
{
    FaceDetector detector(kYunet, kSface);
    detector.setDetectionModes(true, false);

    bool alert = true;
    const auto faces = detector.detect(blankFrame(), alert);

    QVERIFY(faces.empty());
    QCOMPARE(alert, false);
}

void TestFaceDetector::nullImageReturnsNothing()
{
    FaceDetector detector(kYunet, kSface);
    detector.setDetectionModes(true, false);

    bool alert = true;
    const auto faces = detector.detect(QImage(), alert);

    QVERIFY(faces.empty());
    QCOMPARE(alert, false);
}

void TestFaceDetector::skipsAiWhenBothModesOff()
{
    FaceDetector detector(kYunet, kSface);

    bool alert = true;
    for (int i = 0; i < 40; ++i) {
        const auto faces = detector.detect(blankFrame(i % 2 ? Qt::black : Qt::white), alert);
        QVERIFY(faces.empty());
        QCOMPARE(alert, false);
    }
}

void TestFaceDetector::alertFiresOnceAfterThirtyFaceFrames()
{
    FaceDetector detector(kYunet, kSface);

    QList<int> alertFrames;
    for (int frame = 1; frame <= 90; ++frame) {
        if (detector.checkAlertCondition(true))
            alertFrames << frame;
    }

    QCOMPARE(alertFrames, QList<int>{30});
}

void TestFaceDetector::alertCountResetsWhenFaceLost()
{
    FaceDetector detector(kYunet, kSface);

    for (int i = 0; i < 29; ++i)
        QVERIFY(!detector.checkAlertCondition(true));
    QVERIFY(!detector.checkAlertCondition(false));

    for (int i = 0; i < 29; ++i)
        QVERIFY(!detector.checkAlertCondition(true));
    QVERIFY(detector.checkAlertCondition(true));
}

void TestFaceDetector::workerEmitsResultsAndReleasesBusyFlag()
{
    FaceDetectionWorker worker(kYunet, kSface);
    worker.setDetectionModes(true, false);
    QSignalSpy detected(&worker, &FaceDetectionWorker::facesDetected);
    QSignalSpy alerted(&worker, &FaceDetectionWorker::faceAlertTriggered);

    worker.processFrame(blankFrame());

    QCOMPARE(detected.count(), 1);
    QCOMPARE(alerted.count(), 0);
    QVERIFY(!worker.isBusy());
}

QTEST_MAIN(TestFaceDetector)
#include "tst_facedetector.moc"
