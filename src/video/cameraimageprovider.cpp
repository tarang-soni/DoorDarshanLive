#include "video/cameraimageprovider.h"
#include "video/videobridge.h"

CameraImageProvider::CameraImageProvider(VideoBridge *bridge)
    : QQuickImageProvider(QQuickImageProvider::Image),
    m_bridge(bridge)
{
}

QImage CameraImageProvider::requestImage(
    const QString &,
    QSize *size,
    const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);

    QImage img = m_bridge->currentFrame();

    if(size)
        *size = img.size();

    return img;
}