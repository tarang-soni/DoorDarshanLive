#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariantList>
#include <QVariantMap>
#include <QDateTime>
#include <QDebug>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE bool initDatabase();

    // Identity Management
    Q_INVOKABLE bool addIdentity(const QString &name, const QString &imagePath, const QByteArray &faceEncoding);
    Q_INVOKABLE bool removeIdentity(int id);
    Q_INVOKABLE QVariantList getAllIdentities();
    Q_INVOKABLE int getIdentityIdByName(const QString &name);

    // History Logging
    Q_INVOKABLE bool logHistoryEvent(int identityId, bool isKnown, const QString &imagePath, const QByteArray &faceEncoding = QByteArray());
    Q_INVOKABLE QVariantList getHistoryLogs();
    Q_INVOKABLE void clearHistory();

    // Unknown Visitor Promotion
    Q_INVOKABLE bool nameUnknownVisitor(int historyId, const QString &newName);

    // AI Data Feeder
    QVariantList getIdentitiesForAI();

signals:
    void identitiesUpdated();

private:
    QSqlDatabase m_db;
};

#endif // DATABASEMANAGER_H