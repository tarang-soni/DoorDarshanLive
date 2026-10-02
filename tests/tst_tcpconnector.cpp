#include <QtTest>
#include <QTcpSocket>
#include "network/tcpconnector.h"

namespace {

QByteArray bytes(std::initializer_list<ClientResponse> responses)
{
    QByteArray data;
    for (ClientResponse r : responses)
        data.append(static_cast<char>(r));
    return data;
}

}

// Plays the Pi: connects to the desktop's TCP server and exchanges command bytes.
class TestTcpConnector : public QObject
{
    Q_OBJECT

private slots:
    void init();
    void cleanup();

    void listensOnEphemeralPort();
    void reportsConnectAndDisconnect();
    void streamStartedEmitsStreamApproved();
    void streamStoppedEmitsStreamStopped();
    void otherResponsesEmitNothing();
    void handlesResponsesArrivingInOneSegment();
    void transmitsCommandAsSingleByte_data();
    void transmitsCommandAsSingleByte();
    void transmitWithoutClientIsIgnored();

private:
    void connectPi();

    TcpConnector *m_connector = nullptr;
    QTcpSocket *m_pi = nullptr;
};

void TestTcpConnector::init()
{
    m_connector = new TcpConnector(nullptr, QHostAddress::LocalHost, 0);
    m_pi = new QTcpSocket;
}

void TestTcpConnector::cleanup()
{
    delete m_pi;
    delete m_connector;
    m_pi = nullptr;
    m_connector = nullptr;
}

void TestTcpConnector::connectPi()
{
    QSignalSpy connected(m_connector, &TcpConnector::connectedChanged);
    m_pi->connectToHost(QHostAddress::LocalHost, m_connector->getServerPort());
    QVERIFY(m_pi->waitForConnected(3000));
    QTRY_COMPARE(connected.count(), 1);
}

void TestTcpConnector::listensOnEphemeralPort()
{
    QVERIFY(m_connector->getServerPort() != 0);
}

void TestTcpConnector::reportsConnectAndDisconnect()
{
    QSignalSpy spy(m_connector, &TcpConnector::connectedChanged);

    m_pi->connectToHost(QHostAddress::LocalHost, m_connector->getServerPort());
    QVERIFY(m_pi->waitForConnected(3000));
    QTRY_COMPARE(spy.count(), 1);
    QCOMPARE(spy.at(0).at(0).toBool(), true);

    m_pi->disconnectFromHost();
    QTRY_COMPARE(spy.count(), 2);
    QCOMPARE(spy.at(1).at(0).toBool(), false);
}

void TestTcpConnector::streamStartedEmitsStreamApproved()
{
    connectPi();
    QSignalSpy approved(m_connector, &TcpConnector::streamApproved);
    QSignalSpy stopped(m_connector, &TcpConnector::streamStopped);

    m_pi->write(bytes({ClientResponse::StreamStarted}));

    QTRY_COMPARE(approved.count(), 1);
    QCOMPARE(stopped.count(), 0);
}

void TestTcpConnector::streamStoppedEmitsStreamStopped()
{
    connectPi();
    QSignalSpy approved(m_connector, &TcpConnector::streamApproved);
    QSignalSpy stopped(m_connector, &TcpConnector::streamStopped);

    m_pi->write(bytes({ClientResponse::StreamStopped}));

    QTRY_COMPARE(stopped.count(), 1);
    QCOMPARE(approved.count(), 0);
}

void TestTcpConnector::otherResponsesEmitNothing()
{
    connectPi();
    QSignalSpy approved(m_connector, &TcpConnector::streamApproved);
    QSignalSpy stopped(m_connector, &TcpConnector::streamStopped);

    m_pi->write(bytes({ClientResponse::ConnectionSuccess, ClientResponse::Pong,
                       ClientResponse::ErrorDeviceBusy}));
    m_pi->flush();
    QTest::qWait(200);

    QCOMPARE(approved.count(), 0);
    QCOMPARE(stopped.count(), 0);
}

// TCP is a byte stream: two one-byte responses sent back to back can arrive
// in a single readyRead. Each byte is a separate response and must be handled.
void TestTcpConnector::handlesResponsesArrivingInOneSegment()
{
    connectPi();
    QSignalSpy approved(m_connector, &TcpConnector::streamApproved);
    QSignalSpy stopped(m_connector, &TcpConnector::streamStopped);

    m_pi->write(bytes({ClientResponse::StreamStarted, ClientResponse::StreamStopped}));
    m_pi->flush();

    QTRY_COMPARE(approved.count(), 1);
    QTRY_COMPARE(stopped.count(), 1);
}

void TestTcpConnector::transmitsCommandAsSingleByte_data()
{
    QTest::addColumn<ServerCommand>("command");
    QTest::addColumn<char>("expected");

    QTest::newRow("StartStream") << ServerCommand::StartStream << char(0x00);
    QTest::newRow("StopStream") << ServerCommand::StopStream << char(0x01);
    QTest::newRow("Ping") << ServerCommand::Ping << char(0x02);
    QTest::newRow("Reboot") << ServerCommand::Reboot << char(0x03);
    QTest::newRow("Quit") << ServerCommand::Quit << char(0x04);
}

void TestTcpConnector::transmitsCommandAsSingleByte()
{
    QFETCH(ServerCommand, command);
    QFETCH(char, expected);
    connectPi();

    m_connector->onCommandTransmitted(command);

    QVERIFY(m_pi->waitForReadyRead(3000));
    QCOMPARE(m_pi->readAll(), QByteArray(1, expected));
}

void TestTcpConnector::transmitWithoutClientIsIgnored()
{
    m_connector->onCommandTransmitted(ServerCommand::StartStream);
}

QTEST_GUILESS_MAIN(TestTcpConnector)
#include "tst_tcpconnector.moc"
