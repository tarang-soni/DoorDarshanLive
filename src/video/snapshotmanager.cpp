#include "snapshotmanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>
#include <QDebug>

SnapshotManager::SnapshotManager(DatabaseManager* dbManager, QObject *parent)
    : QObject(parent), m_dbManager(dbManager)
{
    // Setup the local storage folder for images
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    m_storagePath = dataDir + "/snapshots";

    QDir dir;
    if (!dir.exists(m_storagePath)) {
        dir.mkpath(m_storagePath);
    }
}

void SnapshotManager::saveSnapshot(const QImage &image, const QByteArray &faceEncoding, bool isKnown, int identityId)
{
    if (image.isNull()) {
        qDebug() << "Cannot save snapshot: Image is empty.";
        return;
    }

    // Generate a unique filename using the exact time
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss_zzz");
    QString filename = QString("snap_%1.jpg").arg(timestamp);
    QString fullPath = m_storagePath + "/" + filename;

    // Save as a high-quality JPG
    if (image.save(fullPath, "JPG", 90)) {
        qDebug() << "Snapshot saved perfectly to:" << fullPath;

        // Log this event into the SQLite History table
        if (m_dbManager) {
            // FIXED: Pass faceEncoding here!
            m_dbManager->logHistoryEvent(identityId, isKnown, fullPath, faceEncoding);
        }
    } else {
        qDebug() << "Failed to write snapshot to disk.";
    }
}