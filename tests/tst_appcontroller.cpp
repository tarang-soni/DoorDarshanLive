#include <QtTest>
#include <QNetworkDatagram>
#include <QStandardPaths>
#include <QTcpSocket>
#include <QUdpSocket>
#include "core/appcontroller.h"
#include "core/utils.h"

// Plays the Pi: answers the UDP connect request by dialling back over TCP.
class FakePi
{
public:
    bool listen()
    {
        return m_udp.bind(QHostAddress::AnyIPv4, DISCOVERY_PORT,
                          QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);
    }

    // Waits for DD_START_TCP:<port> and connects a fresh TCP socket to it.
    bool acceptConnectRequest(QTcpSocket &tcp)
    {
        QElapsedTimer timer;
        timer.start();
        while (timer.elapsed() < 5000) {
            while (m_udp.hasPendingDatagrams()) {
                const QByteArray data = m_udp.receiveDatagram().data();
                if (data.startsWith("DD_START_TCP:")) {
                    const quint16 port = data.mid(13).toUShort();
                    tcp.connectToHost(QHostAddress::LocalHost, port);
                    return tcp.waitForConnected(3000);
                }
            }
            QTest::qWait(20);
        }
        return false;
    }

private:
    QUdpSocket m_udp;
};

class TestAppController : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();

    void streamResponsesDriveIsStreaming();
    void cameraToggleRequestsStream();
    void disconnectStopsStreamingAndReconnectResumes();

private:
    void connectPi(AppController &controller, FakePi &pi, QTcpSocket &tcp);
    static void sendByte(QTcpSocket &tcp, ClientResponse response);
    static QByteArray readCommands(QTcpSocket &tcp);
};

void TestAppController::initTestCase()
{
    QStandardPaths::setTestModeEnabled(true);
}

void TestAppController::init()
{
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QVERIFY2(dataDir.contains("qttest"), qPrintable("Refusing to wipe non-test dir " + dataDir));
    QDir(dataDir).removeRecursively();
}

void TestAppController::connectPi(AppController &controller, FakePi &pi, QTcpSocket &tcp)
{
    controller.uiManager()->connectToPi("127.0.0.1");
    QVERIFY(pi.acceptConnectRequest(tcp));
    QTRY_VERIFY(controller.uiManager()->piConnected());
}

void TestAppController::sendByte(QTcpSocket &tcp, ClientResponse response)
{
    tcp.write(QByteArray(1, char(response)));
    tcp.flush();
}

QByteArray TestAppController::readCommands(QTcpSocket &tcp)
{
    QByteArray received;
    QElapsedTimer timer;
    timer.start();
    while (timer.elapsed() < 1000) {
        if (tcp.bytesAvailable() || tcp.waitForReadyRead(50))
            received += tcp.readAll();
        QTest::qWait(10);
    }
    return received;
}

void TestAppController::streamResponsesDriveIsStreaming()
{
    FakePi pi;
    QVERIFY(pi.listen());
    AppController controller;
    QTcpSocket tcp;
    connectPi(controller, pi, tcp);
    UIManager *ui = controller.uiManager();
    QCOMPARE(ui->isStreaming(), false);

    sendByte(tcp, ClientResponse::StreamStarted);
    QTRY_COMPARE(ui->isStreaming(), true);

    sendByte(tcp, ClientResponse::StreamStopped);
    QTRY_COMPARE(ui->isStreaming(), false);
}

void TestAppController::cameraToggleRequestsStream()
{
    FakePi pi;
    QVERIFY(pi.listen());
    AppController controller;
    QTcpSocket tcp;
    connectPi(controller, pi, tcp);

    controller.uiManager()->setCameraUiEnabled(true);
    QVERIFY(readCommands(tcp).contains(char(ServerCommand::StartStream)));

    controller.uiManager()->setCameraUiEnabled(false);
    QVERIFY(readCommands(tcp).contains(char(ServerCommand::StopStream)));
}

// A Pi that drops off never sends StreamStopped. The app must stop streaming
// on its own, and ask for the stream again once the Pi is back.
void TestAppController::disconnectStopsStreamingAndReconnectResumes()
{
    FakePi pi;
    QVERIFY(pi.listen());
    AppController controller;
    UIManager *ui = controller.uiManager();

    QTcpSocket first;
    connectPi(controller, pi, first);
    ui->setCameraUiEnabled(true);
    readCommands(first);
    sendByte(first, ClientResponse::StreamStarted);
    QTRY_COMPARE(ui->isStreaming(), true);

    first.abort();
    QTRY_COMPARE(ui->piConnected(), false);
    QCOMPARE(ui->isStreaming(), false);

    QTcpSocket second;
    connectPi(controller, pi, second);
    QVERIFY(readCommands(second).contains(char(ServerCommand::StartStream)));
}

QTEST_MAIN(TestAppController)
#include "tst_appcontroller.moc"
