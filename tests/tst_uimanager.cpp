#include <QtTest>
#include "ui/uimanager.h"

class TestUIManager : public QObject
{
    Q_OBJECT

private slots:
    void defaultsAreFalse();
    void boolSettersEmitOnlyOnChange_data();
    void boolSettersEmitOnlyOnChange();
    void connectedIpSetterEmitsOnlyOnChange();
    void streamRequestsEmitSignals();
    void findDevicesEmitsRequest();
    void connectToPiStoresIpAndEmitsRequest();
};

void TestUIManager::defaultsAreFalse()
{
    UIManager ui;
    QCOMPARE(ui.piConnected(), false);
    QCOMPARE(ui.isStreaming(), false);
    QCOMPARE(ui.cameraUiEnabled(), false);
    QCOMPARE(ui.motionEnabled(), false);
    QVERIFY(ui.connectedIp().isEmpty());
}

void TestUIManager::boolSettersEmitOnlyOnChange_data()
{
    QTest::addColumn<QByteArray>("property");
    QTest::addColumn<QByteArray>("notifySignal");

    QTest::newRow("piConnected") << QByteArray("piConnected") << QByteArray(SIGNAL(piConnectedChanged()));
    QTest::newRow("isStreaming") << QByteArray("isStreaming") << QByteArray(SIGNAL(isStreamingChanged()));
    QTest::newRow("cameraUiEnabled") << QByteArray("cameraUiEnabled") << QByteArray(SIGNAL(cameraUiEnabledChanged()));
    QTest::newRow("motionEnabled") << QByteArray("motionEnabled") << QByteArray(SIGNAL(motionEnabledChanged()));
}

void TestUIManager::boolSettersEmitOnlyOnChange()
{
    QFETCH(QByteArray, property);
    QFETCH(QByteArray, notifySignal);

    UIManager ui;
    QSignalSpy spy(&ui, notifySignal.constData());

    QVERIFY(ui.setProperty(property, true));
    QCOMPARE(ui.property(property).toBool(), true);
    QCOMPARE(spy.count(), 1);

    ui.setProperty(property, true);
    QCOMPARE(spy.count(), 1);

    ui.setProperty(property, false);
    QCOMPARE(ui.property(property).toBool(), false);
    QCOMPARE(spy.count(), 2);
}

void TestUIManager::connectedIpSetterEmitsOnlyOnChange()
{
    UIManager ui;
    QSignalSpy spy(&ui, &UIManager::connectedIpChanged);

    ui.setConnectedIp("192.168.1.20");
    QCOMPARE(ui.connectedIp(), QString("192.168.1.20"));
    QCOMPARE(spy.count(), 1);

    ui.setConnectedIp("192.168.1.20");
    QCOMPARE(spy.count(), 1);
}

void TestUIManager::streamRequestsEmitSignals()
{
    UIManager ui;
    QSignalSpy startSpy(&ui, &UIManager::startStreamRequested);
    QSignalSpy stopSpy(&ui, &UIManager::stopStreamRequested);

    ui.requestStartStream();
    ui.requestStopStream();

    QCOMPARE(startSpy.count(), 1);
    QCOMPARE(stopSpy.count(), 1);
}

void TestUIManager::findDevicesEmitsRequest()
{
    UIManager ui;
    QSignalSpy spy(&ui, &UIManager::findDevicesRequested);

    ui.findDevices();

    QCOMPARE(spy.count(), 1);
}

void TestUIManager::connectToPiStoresIpAndEmitsRequest()
{
    UIManager ui;
    QSignalSpy spy(&ui, &UIManager::piConnectionRequested);

    ui.connectToPi("10.0.0.7");

    QCOMPARE(ui.connectedIp(), QString("10.0.0.7"));
    QCOMPARE(spy.count(), 1);
    QCOMPARE(spy.at(0).at(0).toString(), QString("10.0.0.7"));
}

QTEST_GUILESS_MAIN(TestUIManager)
#include "tst_uimanager.moc"
