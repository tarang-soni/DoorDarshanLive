#include <QtTest>
#include <QImage>
#include <QStandardPaths>
#include "core/databasemanager.h"
#include "video/snapshotmanager.h"

class TestSnapshotManager : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();
    void cleanup();

    void savesJpegAndLogsHistory();
    void savesKnownVisitorWithEncoding();
    void ignoresNullImage();

private:
    QString snapshotDir() const;

    DatabaseManager *m_db = nullptr;
    SnapshotManager *m_snapshots = nullptr;
};

void TestSnapshotManager::initTestCase()
{
    QStandardPaths::setTestModeEnabled(true);
}

void TestSnapshotManager::init()
{
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QVERIFY2(dataDir.contains("qttest"), qPrintable("Refusing to wipe non-test dir " + dataDir));
    QDir(dataDir).removeRecursively();

    m_db = new DatabaseManager;
    QVERIFY(m_db->initDatabase());
    m_snapshots = new SnapshotManager(m_db);
}

void TestSnapshotManager::cleanup()
{
    delete m_snapshots;
    delete m_db;
    m_snapshots = nullptr;
    m_db = nullptr;
}

QString TestSnapshotManager::snapshotDir() const
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/snapshots";
}

void TestSnapshotManager::savesJpegAndLogsHistory()
{
    QImage frame(64, 48, QImage::Format_RGBA8888);
    frame.fill(Qt::red);

    m_snapshots->saveSnapshot(frame);

    const QStringList files = QDir(snapshotDir()).entryList({"snap_*.jpg"}, QDir::Files);
    QCOMPARE(files.size(), 1);
    const QString path = snapshotDir() + "/" + files.first();
    QCOMPARE(QImage(path).size(), frame.size());

    const QVariantList logs = m_db->getHistoryLogs();
    QCOMPARE(logs.size(), 1);
    const QVariantMap log = logs.first().toMap();
    QCOMPARE(log["imagePath"].toString(), path);
    QCOMPARE(log["isKnown"].toBool(), false);
}

void TestSnapshotManager::savesKnownVisitorWithEncoding()
{
    QVERIFY(m_db->addIdentity("Asha", "", QByteArray(128 * sizeof(float), '\1')));
    const int ashaId = m_db->getIdentityIdByName("Asha");
    QImage frame(32, 32, QImage::Format_RGBA8888);
    frame.fill(Qt::blue);
    const QByteArray encoding(128 * sizeof(float), '\2');

    m_snapshots->saveSnapshot(frame, encoding, true, ashaId);

    const QVariantMap log = m_db->getHistoryLogs().first().toMap();
    QCOMPARE(log["isKnown"].toBool(), true);
    QCOMPARE(log["visitorName"].toString(), QString("Asha"));

    QSqlQuery query("SELECT face_encoding FROM History");
    QVERIFY(query.next());
    QCOMPARE(query.value(0).toByteArray(), encoding);
}

void TestSnapshotManager::ignoresNullImage()
{
    m_snapshots->saveSnapshot(QImage());

    QVERIFY(QDir(snapshotDir()).entryList(QDir::Files).isEmpty());
    QVERIFY(m_db->getHistoryLogs().isEmpty());
}

QTEST_MAIN(TestSnapshotManager)
#include "tst_snapshotmanager.moc"
