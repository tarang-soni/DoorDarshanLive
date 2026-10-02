#include <QtTest>
#include <QSqlQuery>
#include <QStandardPaths>
#include "core/databasemanager.h"

namespace {

QByteArray fakeEncoding(float seed)
{
    QByteArray bytes(128 * sizeof(float), Qt::Uninitialized);
    auto *values = reinterpret_cast<float *>(bytes.data());
    for (int i = 0; i < 128; ++i)
        values[i] = seed + i;
    return bytes;
}

QVariantMap findBy(const QVariantList &rows, const QString &key, const QVariant &value)
{
    for (const QVariant &row : rows) {
        const QVariantMap map = row.toMap();
        if (map.value(key) == value)
            return map;
    }
    return {};
}

}

class TestDatabaseManager : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();
    void cleanup();

    void initCreatesTables();
    void initIsIdempotent();
    void addIdentityListsAndNotifies();
    void removeIdentityDeletesAndNotifies();
    void identityIdByName();
    void unknownHistoryEventHasNoIdentity();
    void knownHistoryEventJoinsIdentityName();
    void clearHistoryRemovesAllEvents();
    void nameUnknownVisitorPromotesToIdentity();
    void nameUnknownVisitorRejectsMissingHistory();
    void identitiesForAiSkipsInvalidEncodings();
    void deleteHistoryLogRemovesOnlyThatEntry();
    void deleteHistoryLogRejectsMissingId();
    void removeIdentityTurnsTheirVisitsUnknown();
    void countVisitsTodayCountsTodaysEvents();
    void historyTimesAreShownInLocalTime();

private:
    DatabaseManager *m_db = nullptr;
};

void TestDatabaseManager::initTestCase()
{
    QStandardPaths::setTestModeEnabled(true);
}

void TestDatabaseManager::init()
{
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QVERIFY2(dataDir.contains("qttest"), qPrintable("Refusing to wipe non-test dir " + dataDir));
    QDir(dataDir).removeRecursively();

    m_db = new DatabaseManager;
    QVERIFY(m_db->initDatabase());
}

void TestDatabaseManager::cleanup()
{
    delete m_db;
    m_db = nullptr;
}

void TestDatabaseManager::initCreatesTables()
{
    QSqlQuery query("SELECT name FROM sqlite_master WHERE type = 'table'");
    QStringList tables;
    while (query.next())
        tables << query.value(0).toString();

    QVERIFY(tables.contains("Identities"));
    QVERIFY(tables.contains("History"));
}

void TestDatabaseManager::initIsIdempotent()
{
    QVERIFY(m_db->addIdentity("Asha", "/tmp/asha.jpg", fakeEncoding(1)));

    QVERIFY(m_db->initDatabase());

    QCOMPARE(m_db->getAllIdentities().size(), 1);
}

void TestDatabaseManager::addIdentityListsAndNotifies()
{
    QSignalSpy spy(m_db, &DatabaseManager::identitiesUpdated);

    QVERIFY(m_db->addIdentity("Asha", "/tmp/asha.jpg", fakeEncoding(1)));

    QCOMPARE(spy.count(), 1);
    const QVariantList identities = m_db->getAllIdentities();
    QCOMPARE(identities.size(), 1);
    const QVariantMap asha = identities.first().toMap();
    QCOMPARE(asha["personName"].toString(), QString("Asha"));
    QCOMPARE(asha["imagePath"].toString(), QString("/tmp/asha.jpg"));
    QVERIFY(asha["dateAdded"].toString().startsWith("Enrolled: "));
}

void TestDatabaseManager::removeIdentityDeletesAndNotifies()
{
    QVERIFY(m_db->addIdentity("Asha", "/tmp/asha.jpg", fakeEncoding(1)));
    const int id = m_db->getIdentityIdByName("Asha");
    QSignalSpy spy(m_db, &DatabaseManager::identitiesUpdated);

    QVERIFY(m_db->removeIdentity(id));

    QCOMPARE(spy.count(), 1);
    QVERIFY(m_db->getAllIdentities().isEmpty());
}

void TestDatabaseManager::identityIdByName()
{
    QVERIFY(m_db->addIdentity("Asha", "", fakeEncoding(1)));
    QVERIFY(m_db->addIdentity("Ravi", "", fakeEncoding(2)));

    const int asha = m_db->getIdentityIdByName("Asha");
    const int ravi = m_db->getIdentityIdByName("Ravi");

    QVERIFY(asha > 0);
    QVERIFY(ravi > 0);
    QVERIFY(asha != ravi);
    QCOMPARE(m_db->getIdentityIdByName("Nobody"), -1);
}

void TestDatabaseManager::unknownHistoryEventHasNoIdentity()
{
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/snap.jpg"));

    const QVariantList logs = m_db->getHistoryLogs();
    QCOMPARE(logs.size(), 1);
    const QVariantMap log = logs.first().toMap();
    QCOMPARE(log["isKnown"].toBool(), false);
    QCOMPARE(log["visitorName"].toString(), QString("Unknown Visitor"));
    QCOMPARE(log["imagePath"].toString(), QString("/tmp/snap.jpg"));

    QSqlQuery query("SELECT identity_id FROM History");
    QVERIFY(query.next());
    QVERIFY(query.value(0).isNull());
}

void TestDatabaseManager::knownHistoryEventJoinsIdentityName()
{
    QVERIFY(m_db->addIdentity("Asha", "", fakeEncoding(1)));
    const int id = m_db->getIdentityIdByName("Asha");

    QVERIFY(m_db->logHistoryEvent(id, true, "/tmp/snap.jpg"));

    const QVariantMap log = m_db->getHistoryLogs().first().toMap();
    QCOMPARE(log["isKnown"].toBool(), true);
    QCOMPARE(log["visitorName"].toString(), QString("Asha"));
}

void TestDatabaseManager::clearHistoryRemovesAllEvents()
{
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/a.jpg"));
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/b.jpg"));

    m_db->clearHistory();

    QVERIFY(m_db->getHistoryLogs().isEmpty());
}

void TestDatabaseManager::nameUnknownVisitorPromotesToIdentity()
{
    const QByteArray encoding = fakeEncoding(7);
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/visitor.jpg", encoding));
    const int historyId = m_db->getHistoryLogs().first().toMap()["id"].toInt();
    QSignalSpy spy(m_db, &DatabaseManager::identitiesUpdated);

    QVERIFY(m_db->nameUnknownVisitor(historyId, "Meera"));

    QCOMPARE(spy.count(), 1);

    const QVariantMap log = findBy(m_db->getHistoryLogs(), "id", historyId);
    QCOMPARE(log["isKnown"].toBool(), true);
    QCOMPARE(log["visitorName"].toString(), QString("Meera"));

    const QVariantMap identity = findBy(m_db->getAllIdentities(), "personName", "Meera");
    QCOMPARE(identity["imagePath"].toString(), QString("/tmp/visitor.jpg"));

    const QVariantMap aiEntry = findBy(m_db->getIdentitiesForAI(), "name", "Meera");
    QCOMPARE(aiEntry["encoding"].toByteArray(), encoding);
}

void TestDatabaseManager::nameUnknownVisitorRejectsMissingHistory()
{
    QSignalSpy spy(m_db, &DatabaseManager::identitiesUpdated);

    QVERIFY(!m_db->nameUnknownVisitor(9999, "Ghost"));

    QCOMPARE(spy.count(), 0);
    QVERIFY(m_db->getAllIdentities().isEmpty());
}

void TestDatabaseManager::identitiesForAiSkipsInvalidEncodings()
{
    QVERIFY(m_db->addIdentity("Valid", "", fakeEncoding(1)));
    QVERIFY(m_db->addIdentity("TooShort", "", QByteArray(16, '\0')));
    QVERIFY(m_db->addIdentity("NoEncoding", "", QByteArray()));

    const QVariantList forAi = m_db->getIdentitiesForAI();

    QCOMPARE(forAi.size(), 1);
    QCOMPARE(forAi.first().toMap()["name"].toString(), QString("Valid"));
}

void TestDatabaseManager::deleteHistoryLogRemovesOnlyThatEntry()
{
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/a.jpg"));
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/b.jpg"));
    const int doomed = findBy(m_db->getHistoryLogs(), "imagePath", "/tmp/a.jpg")["id"].toInt();

    QVERIFY(m_db->deleteHistoryLog(doomed));

    const QVariantList logs = m_db->getHistoryLogs();
    QCOMPARE(logs.size(), 1);
    QCOMPARE(logs.first().toMap()["imagePath"].toString(), QString("/tmp/b.jpg"));
}

void TestDatabaseManager::deleteHistoryLogRejectsMissingId()
{
    QVERIFY(!m_db->deleteHistoryLog(9999));
}

void TestDatabaseManager::removeIdentityTurnsTheirVisitsUnknown()
{
    QVERIFY(m_db->addIdentity("Asha", "", fakeEncoding(1)));
    const int asha = m_db->getIdentityIdByName("Asha");
    QVERIFY(m_db->logHistoryEvent(asha, true, "/tmp/asha.jpg"));

    QVERIFY(m_db->removeIdentity(asha));

    const QVariantMap log = m_db->getHistoryLogs().first().toMap();
    QCOMPARE(log["isKnown"].toBool(), false);
    QCOMPARE(log["visitorName"].toString(), QString("Unknown Visitor"));
}

void TestDatabaseManager::countVisitsTodayCountsTodaysEvents()
{
    QCOMPARE(m_db->countVisitsToday(), 0);
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/a.jpg"));
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/b.jpg"));
    QSqlQuery old("INSERT INTO History (is_known, image_path, timestamp) "
                  "VALUES (0, '/tmp/old.jpg', datetime('now', '-3 days'))");
    QVERIFY(old.isActive());

    QCOMPARE(m_db->countVisitsToday(), 2);
}

// SQLite stores CURRENT_TIMESTAMP in UTC; the UI must show local time.
void TestDatabaseManager::historyTimesAreShownInLocalTime()
{
    QVERIFY(m_db->logHistoryEvent(-1, false, "/tmp/now.jpg"));

    const QVariantMap log = m_db->getHistoryLogs().first().toMap();
    const QDateTime shown = QDateTime::fromString(log["iso"].toString(), Qt::ISODate);
    QVERIFY(shown.isValid());
    QVERIFY2(qAbs(shown.secsTo(QDateTime::currentDateTime())) < 120,
             qPrintable(log["iso"].toString()));
    QCOMPARE(log["timestamp"].toString(),
             shown.toLocalTime().toString("MMM dd, yyyy - HH:mm"));
}

QTEST_GUILESS_MAIN(TestDatabaseManager)
#include "tst_databasemanager.moc"
