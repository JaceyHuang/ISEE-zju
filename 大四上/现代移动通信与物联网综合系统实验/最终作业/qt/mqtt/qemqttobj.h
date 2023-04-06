#ifndef QEMQTTOBJ_H
#define QEMQTTOBJ_H

#include <QObject>
#include <QTcpSocket>
#include "libemqtt.h"
#include <QTimer>

typedef enum {mqtt_free,mqtt_connecting,mqtt_connected,mqtt_disconnected} mqtt_state;

class QEMqttObj : public QObject
{
    Q_OBJECT
    QTcpSocket* sckt;
    QStringList topicList;
    mqtt_state state;
    bool noAutoRead;
    QTimer *scktTimer;
    int stCount;
    QByteArray scktBuf;
protected:
    mqtt_broker_handle_t broker;
    int init_socket(mqtt_broker_handle_t* broker, const char* hostname, short port);
    int close_socket(mqtt_broker_handle_t* broker);
    int read_packet(int timeout);
    int connect_it(mqtt_broker_handle_t* broker);
    int publish_it(mqtt_broker_handle_t* broker,char* topic,char* payLoad,uint8_t qos);
    void disconnect_it(mqtt_broker_handle_t* broker);

    void showMessage(QString sMsg);
public:
    explicit QEMqttObj(QObject *parent = nullptr);
    ~QEMqttObj();
signals:
    void sigShowMessage(QString msg);
    void sigServerConnected();
    void sigServerDisconnected();
    void sigConnectError(QString sError);
    void sigTopicSubscribed(QString sTopic);
    void sigTopicUnSubscribed(QString sTopic);
    void sigMessagePublished(QString sTopic,QByteArray payload);
    void sigMessageArrived(QString sTopic,QByteArray payload);
public slots:
    void slotConnectServer(QString host, quint16 port, QString user="", QString pwd="");
    void slotPublish(QString sTopic,QByteArray payload,quint8 qos);
    void slotPublishString(QString sTopic,QString payload,quint8 qos);
    void slotSubscribe(QString sTopic,quint8 qos);
    void slotUnSubscribe(QString sTopic);
    void slotDisconnect();
private slots:
    void slotScktConnected();
    void slotScktError(QAbstractSocket::SocketError error);
    void slotScktReady();
    void slotScktDisconnected();
    void slotScktTimerOut();
private:
};

#endif // WIDGET_H
