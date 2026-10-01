#ifndef SNAPSHOTMANAGER_H
#define SNAPSHOTMANAGER_H

#include <QObject>
#include <QImage>
#include <QString>
#include "core/databasemanager.h"

class SnapshotManager : public QObject
{
    Q_OBJECT
public:
    explicit SnapshotManager(DatabaseManager* dbManager, QObject *parent = nullptr);

    // Call this when a face is detected, or when the manual Snapshot button is pressed
    Q_INVOKABLE void saveSnapshot(const QImage &image, const QByteArray &faceEncoding = QByteArray(), bool isKnown = false, int identityId = -1);

private:
    DatabaseManager* m_dbManager;
    QString m_storagePath;
};

#endif // SNAPSHOTMANAGER_H