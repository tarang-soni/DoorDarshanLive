#ifndef FACEAI_H
#define FACEAI_H

#include <QObject>
#include <QImage>
#include <QRect>
#include <QDebug>
#include <atomic>
#include <vector>
#include <memory>
#include <string>
#include <opencv2/objdetect.hpp>
#include <opencv2/imgproc.hpp>
#include <QMetaType>

struct FaceResult {
    QRect box;
    std::string name;
    cv::Mat feature;
};

struct KnownIdentity {
    std::string name;
    cv::Mat feature;
};

Q_DECLARE_METATYPE(std::vector<FaceResult>)
Q_DECLARE_METATYPE(std::vector<KnownIdentity>)

class FaceDetector {
public:
    explicit FaceDetector(const std::string& yunetModelPath, const std::string& sfaceModelPath) {
        m_detector = cv::FaceDetectorYN::create(yunetModelPath, "", cv::Size(320, 320), 0.9f, 0.3f, 5000);
        m_recognizer = cv::FaceRecognizerSF::create(sfaceModelPath, "");
    }

    void setKnownIdentities(const std::vector<KnownIdentity>& identities) {
        m_knownIdentities = identities;
    }

    // NEW: We now accept both states
    void setDetectionModes(bool continuous, bool motionGated) {
        m_continuousDetection = continuous;
        m_motionEnabled = motionGated;
        if (!m_motionEnabled) m_prevGray.release();
    }

    bool checkAlertCondition(bool facesFound) {
        if (facesFound) {
            m_faceFramesCount++;
            if (m_faceFramesCount == m_framesForAlert) {
                return true;
            }
        } else {
            m_faceFramesCount = 0;
        }
        return false;
    }

    std::vector<FaceResult> detect(const QImage& image, bool &outAlertTriggered) {
        std::vector<FaceResult> results;
        outAlertTriggered = false;
        if (m_detector.empty() || image.isNull()) return results;

        QImage rgb = image.convertToFormat(QImage::Format_RGB888);
        cv::Mat mat(rgb.height(), rgb.width(), CV_8UC3, const_cast<uchar*>(rgb.bits()), rgb.bytesPerLine());
        cv::Mat bgrMat;
        cv::cvtColor(mat, bgrMat, cv::COLOR_RGB2BGR);
        cv::Mat smallMat;
        cv::resize(bgrMat, smallMat, cv::Size(), 0.5, 0.5, cv::INTER_LINEAR);

        // --- 1. DETERMINE IF WE SHOULD RUN AI ---
        bool shouldRunAI = false;

        if (m_continuousDetection) {
            // Camera is ON: Always run AI so the bounding box doesn't flicker
            shouldRunAI = true;
        }
        else if (m_motionEnabled) {
            // Camera is OFF, Motion is ON: Use lightweight motion differencing
            cv::Mat gray;
            cv::cvtColor(smallMat, gray, cv::COLOR_BGR2GRAY);

            if (m_prevGray.empty()) {
                m_prevGray = gray.clone();
            } else {
                cv::Mat diff, thresh;
                cv::absdiff(m_prevGray, gray, diff);
                cv::threshold(diff, thresh, 25, 255, cv::THRESH_BINARY);
                int motionPixels = cv::countNonZero(thresh);

                // NEW COOLDOWN LOGIC: If motion detected, wake up AI for 60 frames
                if (motionPixels > 500) {
                    m_motionCooldown = 60;
                }
                m_prevGray = gray.clone();
            }

            // Keep AI running as long as the cooldown is active
            if (m_motionCooldown > 0) {
                shouldRunAI = true;
                m_motionCooldown--;
            }
        }

        // --- 2. RUN AI (AND CHECK ALERTS) ---
        if (shouldRunAI) {
            m_detector->setInputSize(smallMat.size());
            cv::Mat faces;
            m_detector->detect(smallMat, faces);

            bool faceFoundThisFrame = !faces.empty();
            outAlertTriggered = checkAlertCondition(faceFoundThisFrame);

            if (faceFoundThisFrame) {
                for (int i = 0; i < faces.rows; i++) {
                    int x = faces.at<float>(i, 0) * 2;
                    int y = faces.at<float>(i, 1) * 2;
                    int w = faces.at<float>(i, 2) * 2;
                    int h = faces.at<float>(i, 3) * 2;

                    std::string detectedName = "Unknown";
                    cv::Mat feature;

                    if (!m_recognizer.empty()) {
                        cv::Mat alignedFace;
                        m_recognizer->alignCrop(smallMat, faces.row(i), alignedFace);
                        m_recognizer->feature(alignedFace, feature);

                        if (!m_knownIdentities.empty()) {
                            double maxScore = 0.0;
                            for (const auto& known : m_knownIdentities) {
                                double score = m_recognizer->match(feature, known.feature, 0);
                                if (score >= 0.363 && score > maxScore) {
                                    maxScore = score;
                                    detectedName = known.name;
                                }
                            }
                        }
                    }
                    results.push_back({QRect(x, y, w, h), detectedName, feature.clone()});
                }
            }
        } else {
            // No motion and cooldown expired, reset the alert timer
            checkAlertCondition(false);
        }

        return results;
    }

private:
    cv::Ptr<cv::FaceDetectorYN> m_detector;
    cv::Ptr<cv::FaceRecognizerSF> m_recognizer;
    std::vector<KnownIdentity> m_knownIdentities;

    bool m_continuousDetection = false;
    bool m_motionEnabled = false;
    cv::Mat m_prevGray;
    int m_faceFramesCount = 0;
    const int m_framesForAlert = 30; // Approx 1 second of face presence
    int m_motionCooldown = 0;
};

class FaceDetectionWorker : public QObject {
    Q_OBJECT
public:
    explicit FaceDetectionWorker(const std::string& yunetModelPath, const std::string& sfaceModelPath)
        : m_detector(std::make_unique<FaceDetector>(yunetModelPath, sfaceModelPath)), m_isBusy(false) {
        qRegisterMetaType<std::vector<FaceResult>>("std::vector<FaceResult>");
    }
    bool isBusy() const { return m_isBusy.load(std::memory_order_relaxed); }

public slots:
    void processFrame(QImage frame) {
        if (m_isBusy.exchange(true)) return;
        bool alertTriggered = false;
        auto faces = m_detector->detect(frame, alertTriggered);

        emit facesDetected(faces);
        if (alertTriggered) emit faceAlertTriggered();

        m_isBusy.store(false, std::memory_order_relaxed);
    }

    void updateIdentities(const std::vector<KnownIdentity>& identities) {
        m_detector->setKnownIdentities(identities);
    }

    void setDetectionModes(bool continuous, bool motionGated) {
        m_detector->setDetectionModes(continuous, motionGated);
    }

signals:
    void facesDetected(const std::vector<FaceResult>& faces);
    void faceAlertTriggered();

private:
    std::unique_ptr<FaceDetector> m_detector;
    std::atomic<bool> m_isBusy;
};

#endif // FACEAI_H