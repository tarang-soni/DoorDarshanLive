#include "databasemanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QTimeZone>

namespace {

// SQLite CURRENT_TIMESTAMP is UTC; show it in the user's local time.
QDateTime localTime(const QVariant &utcValue)
{
    QDateTime dt = utcValue.toDateTime();
    dt.setTimeZone(QTimeZone::UTC);
    return dt.toLocalTime();
}

}

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::initDatabase()
{
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);
    QString dbPath = dataDir + "/doordarshan.db";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qDebug() << "Error: Could not open database:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery query;

    // 1. Create Identities Table
    QString createIdentitiesTable =
        "CREATE TABLE IF NOT EXISTS Identities ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT NOT NULL, "
        "image_path TEXT, "
        "face_encoding BLOB, "
        "date_added DATETIME DEFAULT CURRENT_TIMESTAMP)";
    query.exec(createIdentitiesTable);

    // 2. Create History Table
    QString createHistoryTable =
        "CREATE TABLE IF NOT EXISTS History ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "identity_id INTEGER, "
        "is_known INTEGER NOT NULL, "
        "image_path TEXT, "
        "face_encoding BLOB, "
        "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)";
    query.exec(createHistoryTable);

    // Safe migration: add column in case the database existed previously without it
    query.exec("ALTER TABLE History ADD COLUMN face_encoding BLOB");
    query.exec("ALTER TABLE Identities ADD COLUMN face_encoding BLOB");

    qDebug() << "Database initialized successfully at:" << dbPath;
    return true;
}

bool DatabaseManager::addIdentity(const QString &name, const QString &imagePath, const QByteArray &faceEncoding)
{
    QSqlQuery query;
    query.prepare("INSERT INTO Identities (name, image_path, face_encoding) VALUES (:name, :image_path, :face_encoding)");
    query.bindValue(":name", name);
    query.bindValue(":image_path", imagePath);
    query.bindValue(":face_encoding", faceEncoding);

    bool ok = query.exec();
    if (ok) {
        emit identitiesUpdated();
    }
    return ok;
}

bool DatabaseManager::removeIdentity(int id)
{
    QSqlQuery query;
    query.prepare("DELETE FROM Identities WHERE id = :id");
    query.bindValue(":id", id);
    bool ok = query.exec();
    if (ok) {
        // Their past visits would otherwise stay "known" with no name to show.
        query.prepare("UPDATE History SET is_known = 0, identity_id = NULL WHERE identity_id = :id");
        query.bindValue(":id", id);
        query.exec();
        emit identitiesUpdated();
    }
    return ok;
}

int DatabaseManager::getIdentityIdByName(const QString &name)
{
    QSqlQuery query;
    query.prepare("SELECT id FROM Identities WHERE name = :name LIMIT 1");
    query.bindValue(":name", name);
    if (query.exec() && query.next()) {
        return query.value("id").toInt();
    }
    return -1;
}

QVariantList DatabaseManager::getAllIdentities()
{
    QVariantList list;
    QSqlQuery query("SELECT id, name, image_path, date_added FROM Identities ORDER BY date_added DESC");
    while (query.next()) {
        QVariantMap map;
        map["id"] = query.value("id").toInt();
        map["personName"] = query.value("name").toString();
        map["imagePath"] = query.value("image_path").toString();
        QDateTime dt = localTime(query.value("date_added"));
        map["dateAdded"] = "Enrolled: " + dt.toString("MMM dd, yyyy");
        map["addedOn"] = dt.toString("MMM d, yyyy");
        list.append(map);
    }
    return list;
}

bool DatabaseManager::logHistoryEvent(int identityId, bool isKnown, const QString &imagePath, const QByteArray &faceEncoding)
{
    QSqlQuery query;
    query.prepare("INSERT INTO History (identity_id, is_known, image_path, face_encoding) VALUES (:identity_id, :is_known, :image_path, :face_encoding)");
    query.bindValue(":identity_id", identityId > 0 ? identityId : QVariant(QMetaType::fromType<int>()));
    query.bindValue(":is_known", isKnown ? 1 : 0);
    query.bindValue(":image_path", imagePath);
    query.bindValue(":face_encoding", faceEncoding);

    return query.exec();
}

QVariantList DatabaseManager::getHistoryLogs()
{
    QVariantList list;
    QString sql =
        "SELECT h.id, h.is_known, h.image_path, h.timestamp, i.name "
        "FROM History h "
        "LEFT JOIN Identities i ON h.identity_id = i.id "
        "ORDER BY h.timestamp DESC";

    QSqlQuery query(sql);
    while (query.next()) {
        QVariantMap map;
        map["id"] = query.value("id").toInt();
        bool isKnown = query.value("is_known").toBool();
        map["isKnown"] = isKnown;
        map["visitorName"] = isKnown ? query.value("name").toString() : "Unknown Visitor";
        map["imagePath"] = query.value("image_path").toString();

        QDateTime dt = localTime(query.value("timestamp"));
        map["timestamp"] = dt.toString("MMM dd, yyyy - HH:mm");
        map["iso"] = dt.toString(Qt::ISODate);

        list.append(map);
    }
    return list;
}

void DatabaseManager::clearHistory()
{
    QSqlQuery query("DELETE FROM History");
    query.exec();
}

bool DatabaseManager::deleteHistoryLog(int historyId)
{
    QSqlQuery query;
    query.prepare("DELETE FROM History WHERE id = :id");
    query.bindValue(":id", historyId);
    return query.exec() && query.numRowsAffected() > 0;
}

int DatabaseManager::countVisitsToday()
{
    QSqlQuery query("SELECT COUNT(*) FROM History "
                    "WHERE date(timestamp, 'localtime') = date('now', 'localtime')");
    return query.next() ? query.value(0).toInt() : 0;
}

bool DatabaseManager::nameUnknownVisitor(int historyId, const QString &newName)
{
    QSqlQuery query;
    query.prepare("SELECT image_path, face_encoding FROM History WHERE id = :id");
    query.bindValue(":id", historyId);

    if (!query.exec() || !query.next()) {
        qDebug() << "Could not find history log with ID:" << historyId;
        return false;
    }

    QString imagePath = query.value("image_path").toString();
    QByteArray encoding = query.value("face_encoding").toByteArray();

    query.prepare("INSERT INTO Identities (name, image_path, face_encoding) VALUES (:name, :image_path, :encoding)");
    query.bindValue(":name", newName);
    query.bindValue(":image_path", imagePath);
    query.bindValue(":encoding", encoding);

    if (!query.exec()) {
        qDebug() << "Failed to create new identity:" << query.lastError().text();
        return false;
    }

    int newIdentityId = query.lastInsertId().toInt();

    query.prepare("UPDATE History SET is_known = 1, identity_id = :identity_id WHERE id = :history_id");
    query.bindValue(":identity_id", newIdentityId);
    query.bindValue(":history_id", historyId);

    bool success = query.exec();
    if (success) {
        qDebug() << "Successfully promoted visitor to known:" << newName;
        emit identitiesUpdated();
    }
    return success;
}

QVariantList DatabaseManager::getIdentitiesForAI()
{
    QVariantList list;
    QSqlQuery query("SELECT name, face_encoding FROM Identities WHERE face_encoding IS NOT NULL");
    while (query.next()) {
        QByteArray enc = query.value("face_encoding").toByteArray();
        if (enc.size() == 128 * sizeof(float)) {
            QVariantMap map;
            map["name"] = query.value("name").toString();
            map["encoding"] = enc;
            list.append(map);
        }
    }
    return list;
}