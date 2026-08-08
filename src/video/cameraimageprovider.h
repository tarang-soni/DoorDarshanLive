#ifndef CAMERAIMAGEPROVIDER_H
#define CAMERAIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QMutex>

class VideoBridge;

class CameraImageProvider : public QQuickImageProvider
{
public:
    explicit CameraImageProvider(VideoBridge *bridge);

    QImage requestImage(const QString &id,
                        QSize *size,
                        const QSize &requestedSize) override;

private:
    VideoBridge *m_bridge;
};

#endif