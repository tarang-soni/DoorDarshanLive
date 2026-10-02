#include <QtTest>
#include <QNetworkDatagram>
#include <QTcpSocket>
#include <QUdpSocket>
#include "core/utils.h"
#include "network/discoveryservice.h"
#include "network/networkmanager.h"

// Plays the Pi's UDP side: listens on DISCOVERY_PORT like the backend does.
class FakePi
{
public:
    bool listen()
    {
        return m_socket.bind(QHostAddress::AnyIPv4, DISCOVERY_PORT,
                             QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);
    }

    QNetworkDatagram waitForDatagram(const QByteArray &prefix, int timeoutMs = 5000)
    {
        QElapsedTimer timer;
        timer.start();
        while (timer.elapsed() < timeoutMs) {
            while (m_socket.hasPendingDatagrams()) {
                QNetworkDatagram datagram = m_socket.receiveDatagram();
                if (datagram.data().startsWith(prefix))
                    return datagram;
            }
            QTest::qWait(20);
        }
        return {};
    }

    void reply(const QNetworkDatagram &to, const QByteArray &data)
    {
        m_socket.writeDatagram(data, QHostAddress::LocalHost, to.senderPort());
    }

private:
    QUdpSocket m_socket;
};

class TestNetworkManager : public QObject
{
    Q_OBJECT

private slots:
    void discoveryReportsEachReplyingDeviceOnce();
    void discoveryIgnoresUnrelatedDatagrams();
    void discoveryFinishesAfterThreeBroadcasts();
    void connectToPiAdvertisesReachableTcpPort();
    void streamCommandsReachConnectedPi();

private:
    static quint16 advertisedPort(const QByteArray &packet);
};

quint16 TestNetworkManager::advertisedPort(const QByteArray &packet)
{
    return quint16(packet.mid(QByteArray("DD_START_TCP:").size()).toInt());
}

void TestNetworkManager::discoveryReportsEachReplyingDeviceOnce()
{
    FakePi pi;
    QVERIFY(pi.listen());
    DiscoveryService discovery;
    QSignalSpy found(&discovery, &DiscoveryService::deviceFound);

    discovery.discover();
    const QNetworkDatagram probe = pi.waitForDatagram("DD_DISCOVERY");
    if (!probe.isValid())
        QSKIP("Broadcast datagrams are not looped back on this host");

    pi.reply(probe, "DD_REPLY");
    pi.reply(probe, "DD_REPLY");

    QTRY_COMPARE(found.count(), 1);
    QTest::qWait(200);
    QCOMPARE(found.count(), 1);
    QCOMPARE(found.at(0).at(0).toString(), QString("127.0.0.1"));
}

void TestNetworkManager::discoveryIgnoresUnrelatedDatagrams()
{
    FakePi pi;
    QVERIFY(pi.listen());
    DiscoveryService discovery;
    QSignalSpy found(&discovery, &DiscoveryService::deviceFound);

    discovery.discover();
    const QNetworkDatagram probe = pi.waitForDatagram("DD_DISCOVERY");
    if (!probe.isValid())
        QSKIP("Broadcast datagrams are not looped back on this host");

    pi.reply(probe, "HELLO");
    QTest::qWait(300);

    QCOMPARE(found.count(), 0);
}

// Each round broadcasts once per network interface, so a host with several
// interfaces receives several probes per round. Rounds are 3 s apart; count
// rounds by grouping probes that arrive within a second of each other.
void TestNetworkManager::discoveryFinishesAfterThreeBroadcasts()
{
    FakePi pi;
    QVERIFY(pi.listen());
    DiscoveryService discovery;
    QSignalSpy finished(&discovery, &DiscoveryService::discoveryFinished);
    QElapsedTimer clock;
    clock.start();

    discovery.discover();

    int rounds = 0;
    qint64 lastProbeAt = -1;
    while (pi.waitForDatagram("DD_DISCOVERY", 4000).isValid()) {
        const qint64 now = clock.elapsed();
        if (lastProbeAt < 0 || now - lastProbeAt > 1000)
            ++rounds;
        lastProbeAt = now;
    }
    QTRY_COMPARE_WITH_TIMEOUT(finished.count(), 1, 5000);
    if (rounds == 0)
        QSKIP("Broadcast datagrams are not looped back on this host");
    QCOMPARE(rounds, 3);
}

// The Pi connects back to whatever port the desktop advertises, so that
// port must be the real (unsigned) TCP server port.
void TestNetworkManager::connectToPiAdvertisesReachableTcpPort()
{
    FakePi pi;
    QVERIFY(pi.listen());
    NetworkManager network;

    network.connectToPi("127.0.0.1");

    const QNetworkDatagram request = pi.waitForDatagram("DD_START_TCP:");
    QVERIFY(request.isValid());
    bool ok = false;
    const int port = request.data().mid(QByteArray("DD_START_TCP:").size()).toInt(&ok);
    QVERIFY2(ok, request.data().constData());
    QVERIFY2(port > 0 && port <= 65535, request.data().constData());

    QTcpSocket socket;
    socket.connectToHost(QHostAddress::LocalHost, quint16(port));
    QVERIFY2(socket.waitForConnected(3000),
             qPrintable(QString("%1 from %2:%3: %4").arg(QString(request.data()),
                        request.senderAddress().toString()).arg(request.senderPort())
                        .arg(socket.errorString())));
}

void TestNetworkManager::streamCommandsReachConnectedPi()
{
    FakePi pi;
    QVERIFY(pi.listen());
    NetworkManager network;
    QSignalSpy connected(&network, &NetworkManager::piConnectedChanged);

    network.connectToPi("127.0.0.1");
    const QNetworkDatagram request = pi.waitForDatagram("DD_START_TCP:");
    QVERIFY(request.isValid());

    QTcpSocket socket;
    socket.connectToHost(QHostAddress::LocalHost, advertisedPort(request.data()));
    QVERIFY(socket.waitForConnected(3000));
    QTRY_COMPARE(connected.count(), 1);
    QCOMPARE(connected.at(0).at(0).toBool(), true);

    network.startStream();
    QVERIFY(socket.waitForReadyRead(3000));
    QCOMPARE(socket.readAll(), QByteArray(1, char(ServerCommand::StartStream)));

    network.stopStream();
    QVERIFY(socket.waitForReadyRead(3000));
    QCOMPARE(socket.readAll(), QByteArray(1, char(ServerCommand::StopStream)));
}

QTEST_GUILESS_MAIN(TestNetworkManager)
#include "tst_networkmanager.moc"
