#include "qemqttobj.h"
#include <QEventLoop>
#include <QHostAddress>
#include <QTime>
#include <QUuid>
#include "libemqtt.h"

#define RCVBUFSIZE 1024
uint8_t packet_buffer[RCVBUFSIZE];

int send_packet(void* socket_info, const void* buf, unsigned int count)
{
    //qWarning(QString("Send %1 bytes...").arg(count).toUtf8());
    QTcpSocket* the_sckt = (QTcpSocket*)socket_info;
    return (int)the_sckt->write((const char*)buf, count);
}

QEMqttObj::QEMqttObj(QObject *parent) :
    QObject(parent)
{
    sckt = NULL;
    state = mqtt_free;
    noAutoRead = false;
    scktTimer = NULL;
}

QEMqttObj::~QEMqttObj()
{
    if( sckt ){
        slotDisconnect();
    }
}

void QEMqttObj::showMessage(QString sMsg)
{
    //emit sigShowMessage(sMsg);
    //qWarning(sMsg.toUtf8());
}

int QEMqttObj::init_socket(mqtt_broker_handle_t* broker, const char* hostname, short port)
{
    int flag = 1;
    int keepalive = 300; // Seconds

    // Create the socket
    sckt = new QTcpSocket(this);
    if(!sckt)
        return -1;

    // Disable Nagle Algorithm
    sckt->setSocketOption(QAbstractSocket::LowDelayOption,1);

    connect(sckt,SIGNAL(connected()),this,SLOT(slotScktConnected()));
    connect(sckt,SIGNAL(readyRead()),this,SLOT(slotScktReady()));
    connect(sckt,SIGNAL(disconnected()),this,SLOT(slotScktDisconnected()));
    connect(sckt,SIGNAL(error(QAbstractSocket::SocketError)),this,SLOT(slotScktError(QAbstractSocket::SocketError)));

    // Connect the socket
    sckt->connectToHost(QHostAddress(hostname),port);

    // MQTT stuffs
    mqtt_set_alive(broker, keepalive);
    broker->socket_info = (void*)sckt;
    broker->send = send_packet;

    scktTimer = new QTimer(this);
    connect(scktTimer,SIGNAL(timeout()),this,SLOT(slotScktTimerOut()));
    scktTimer->start(500);
    stCount = 0;

    return 0;
}

int QEMqttObj::close_socket(mqtt_broker_handle_t* broker)
{
    QTcpSocket* the_sckt = (QTcpSocket*)broker->socket_info;
    if( the_sckt ){
        the_sckt->disconnectFromHost();
        the_sckt->deleteLater();
        broker->socket_info = NULL;
    }
    sckt = NULL;

    scktTimer->deleteLater();
    scktTimer = NULL;
    return 0;
}

int QEMqttObj::read_packet(int timeout)
{
    //qWarning(QString("read_packet at to=%1s").arg(timeout).toUtf8());
    noAutoRead = true;
    int total_bytes = 0, bytes_rcvd, packet_length;
    memset(packet_buffer, 0, sizeof(packet_buffer));

    QTime wt_tm;
    wt_tm.start();
    QEventLoop evtLop;
    while(total_bytes < 2) // Reading fixed header
    {
        wt_tm.restart();
        while(sckt->bytesAvailable()<=0){
            evtLop.processEvents(QEventLoop::AllEvents);
            if( wt_tm.elapsed()>timeout*1000 ){
                noAutoRead = false;
                return -1;
            }
        }
        bytes_rcvd = sckt->read((char*)(packet_buffer+total_bytes), RCVBUFSIZE);
        total_bytes += bytes_rcvd; // Keep tally of total bytes
    }

    packet_length = packet_buffer[1] + 2; // Remaining length + fixed header length

    while(total_bytes < packet_length) // Reading the packet
    {
        wt_tm.restart();
        while(sckt->bytesAvailable()<=0){
            evtLop.processEvents(QEventLoop::AllEvents);
            if( wt_tm.elapsed()>timeout*1000 ){
                noAutoRead = false;
                return -1;
            }
        }
        bytes_rcvd = sckt->read((char*)(packet_buffer+total_bytes), RCVBUFSIZE);
        total_bytes += bytes_rcvd; // Keep tally of total bytes
    }

    //qWarning(QString("read_packet ended size=%1").arg(packet_length).toUtf8());
    noAutoRead = false;
    return packet_length;
}

int QEMqttObj::connect_it(mqtt_broker_handle_t* broker)
{
    int packet_length;
    // >>>>> CONNECT
    if( mqtt_connect(broker)!=1 ){
        showMessage("error,mqtt_connect failed!");
        emit sigShowMessage("error,mqtt_connect failed!");
    }
    // <<<<< CONNACK
    packet_length = read_packet(1);
    if(packet_length < 0)
    {
        showMessage(QString("Error,%1 on read packet!").arg(packet_length));
        emit sigShowMessage(QString("Error,%1 on read packet!").arg(packet_length));
        return -1;
    }

    if(MQTTParseMessageType(packet_buffer) != MQTT_MSG_CONNACK)
    {
        showMessage("error,CONNACK expected!");
        emit sigShowMessage("error,CONNACK expected!");
        return -2;
    }

    if(packet_buffer[3] != 0x00)
    {
        showMessage("error,CONNACK failed!");
        emit sigShowMessage("error,CONNACK failed!");
        return -3;
    }
    return 0;
}

int QEMqttObj::publish_it(mqtt_broker_handle_t* broker,char* topic,char* payLoad,uint8_t qos)
{
    uint16_t msg_id, msg_id_rcv;
    int packet_length;

    // >>>>> PUBLISH QoS 0
    //printf("Publish: QoS %d\n",qos);
    mqtt_publish_with_qos(broker, topic, payLoad, 0, qos%3, &msg_id);
    if( (qos%3)>0 ){
        packet_length = read_packet(1);
        if(packet_length < 0)
        {
            showMessage(QString("Error,%1 on read packet!").arg(packet_length));
            emit sigShowMessage(QString("Error,%1 on read packet!").arg(packet_length));
            return -1;
        }

        if(MQTTParseMessageType(packet_buffer) != MQTT_MSG_PUBACK)
        {
            showMessage("Error,PUBACK expected!");
            emit sigShowMessage("Error,PUBACK expected!");
            return -2;
        }

        msg_id_rcv = mqtt_parse_msg_id(packet_buffer);
        if(msg_id != msg_id_rcv)
        {
            showMessage(QString("Error,%1 message id was expected, but %2 message id was found!").arg(msg_id).arg(msg_id_rcv));
            emit sigShowMessage(QString("Error,%1 message id was expected, but %2 message id was found!").arg(msg_id).arg(msg_id_rcv));
            return -3;
        }
    }
    return 0;
}

void QEMqttObj::disconnect_it(mqtt_broker_handle_t* broker)
{
    // >>>>> DISCONNECT
    mqtt_disconnect(broker);
    //close_socket(broker);
}

void QEMqttObj::slotConnectServer(QString host, quint16 port,QString user,QString pwd)
{
    if( state!=mqtt_free ){
        showMessage("current state is not free!disconnect first!");
        emit sigShowMessage("current state is not free!disconnect first!");
        return;
    }
    topicList.clear();
    state = mqtt_connecting;
    mqtt_init(&broker, QUuid::createUuid().toString().toLatin1().data());
    if( user.size()==0 && pwd.size()==0 )
        mqtt_init_auth(&broker, NULL,NULL);
    else
        mqtt_init_auth(&broker, user.toUtf8().data(),pwd.toUtf8().data());
    int conn_ret = init_socket(&broker, host.toLatin1().data(),port);
    if( conn_ret<0 ){
        showMessage(QString("init socket error,return=%1").arg(conn_ret));
        emit sigShowMessage(QString("init socket error,return=%1").arg(conn_ret));
        sckt->abort();
        sckt->deleteLater();
        sckt = NULL;
        broker.socket_info = NULL;
        state = mqtt_free;
    }
    QEventLoop lop;
    QTime wt_tm;
    wt_tm.start();
    while(wt_tm.elapsed()<8000){
        if( sckt->state()==QAbstractSocket::ConnectedState )
            break;
        lop.processEvents(QEventLoop::AllEvents);
    }
    if( sckt->state()==QAbstractSocket::ConnectedState ){
        if( connect_it(&broker)==0 ){
            emit sigServerConnected();
            state = mqtt_connected;
            return;
        }
    }
    else {
        sckt->abort();
    }
    close_socket(&broker);
    state = mqtt_free;
}

void QEMqttObj::slotPublish(QString sTopic, QByteArray payload, quint8 qos)
{
    if( state!=mqtt_connected ){
        showMessage("please connect server first!");
        emit sigShowMessage("please connect server first!");
        return;
    }
    if( publish_it(&broker,sTopic.toUtf8().data(),payload.data(),qos)==0 )
        emit sigMessagePublished(sTopic,payload);
}

void QEMqttObj::slotPublishString(QString sTopic, QString payload, quint8 qos)
{
    slotPublish(sTopic,payload.toUtf8(),qos);
}

void QEMqttObj::slotSubscribe(QString sTopic, quint8 qos)
{
    if( state!=mqtt_connected ){
        showMessage("please connect server first!");
        emit sigShowMessage("please connect server first!");
        return;
    }
    if( topicList.indexOf(sTopic)>=0 ){
        showMessage("allready subscribed!");
        emit sigShowMessage("allready subscribed!");
        return;
    }
    if( mqtt_subscribe(&broker,sTopic.toUtf8().data(),NULL)>=0 ){
        topicList.append(sTopic);
        emit sigTopicSubscribed(sTopic);
    }
    else {
        emit sigShowMessage("subscribe error!");
    }
}

void QEMqttObj::slotUnSubscribe(QString sTopic)
{
    if( state!=mqtt_connected ){
        showMessage("please connect server first!");
        emit sigShowMessage("please connect server first!");
        return;
    }
    int idx = topicList.indexOf(sTopic);
    if( idx<0 ){
        showMessage("topic not subscribed!");
        emit sigShowMessage("topic not subscribed!");
        return;
    }
    if( mqtt_unsubscribe(&broker,sTopic.toUtf8().data(),NULL)>=0 ){
        topicList.removeAt(idx);
        emit sigTopicUnSubscribed(sTopic);
    }
}

void QEMqttObj::slotDisconnect()
{
    if( state!=mqtt_connected ){
        showMessage("not connected state!");
        emit sigShowMessage("not connected state!");
        return;
    }
    foreach (QString sTopic, topicList) {
        mqtt_unsubscribe(&broker,sTopic.toUtf8().data(),NULL);
        emit sigTopicUnSubscribed(sTopic);
    }
    topicList.clear();
    disconnect_it(&broker);
    state = mqtt_disconnected;
    close_socket(&broker);
    state = mqtt_free;
    emit sigServerDisconnected();
}

void QEMqttObj::slotScktConnected()
{
    showMessage("socket connected!");
    emit sigServerConnected();
}

void QEMqttObj::slotScktTimerOut()
{
    slotScktReady();
    stCount++;
    if( stCount>60 ){
        stCount = 0;
        mqtt_ping(&broker);
    }
    if( sckt->bytesAvailable()>0 )
        emit sigShowMessage(QString("msgBuf.size=").arg(sckt->bytesAvailable()));
}

void QEMqttObj::slotScktReady()
{
    if( noAutoRead )    return;
    if( !sckt )         return;
    while( scktBuf.size()>0 && scktBuf.data()[0]!=0x30 )// (scktBuf.data()[0]==0x0a || scktBuf.data()[0]==0xd0 || scktBuf.data()[0]==0x0) )
        scktBuf.remove(0,1);
    if( scktBuf.size()>0 && scktBuf.data()[0]!=0x30 ){
        //emit sigShowMessage(QString("clear buffer!size=%1 \n-- %2").arg(scktBuf.size()).arg(QString::fromLatin1(scktBuf.toHex())));
        scktBuf.clear();
        return;
    }
    if( sckt->bytesAvailable()<=0 ) return;
    while( sckt->bytesAvailable()>0 ){
        QByteArray ba;
        ba = sckt->readAll();
        scktBuf.append(ba);
        if( scktBuf.size()>4 ){
            uchar *ptr = (uchar*)scktBuf.data();
            quint32 uSize = 0;
            int posTopicSize = 3;
            do{
                uSize = ptr[1]&0x7f;
                if( ptr[1]<128 ){
                    break;
                }
                posTopicSize++;
                uSize += (quint32)(ptr[2]&0x7f)*128;
                if( ptr[2]<128 ){
                    break;
                }
                posTopicSize++;
                uSize += (quint32)(ptr[3]&0x7f)*128*128;
                if( ptr[3]<128 ){
                    break;
                }
            }while(0);
            uSize += 2;
            if( ptr[0]==0x30 && scktBuf.size()>=uSize ){
                ba = scktBuf.left(uSize);
                scktBuf.remove(0,uSize);
                //qWarning(ba.toHex());
                ptr = (uchar*)ba.data();
                quint32 topicsize = ptr[posTopicSize];
                //emit sigShowMessage(QString("Sckt content.len=%1,flag=%2,totalsize=%3,topicsize=%4").arg(ba.size()).arg(ptr[0]).arg(uSize).arg(topicsize));
                QString sTopic = QString::fromUtf8(ba.mid(posTopicSize+1,topicsize));
                QString sPayload = QString::fromUtf8(ba.mid(posTopicSize+1+topicsize));
                //emit sigShowMessage(QString("Message:%1 @ %2").arg(sPayload).arg(sTopic));
                emit sigMessageArrived(sTopic,ba.mid(posTopicSize+1+topicsize));
                mqtt_ping(&broker);
            }
            else{
                if( ptr[0]==0x30 )
                    emit sigShowMessage(QString("size not match!- %1>=%2,flag=%3").arg(scktBuf.size()).arg(uSize).arg(ptr[0]));
            }
        }
    }
}

void QEMqttObj::slotScktError(QAbstractSocket::SocketError error)
{
    showMessage(QString("socket error:%1[%2]").arg(sckt->errorString()).arg(error));
    emit sigShowMessage(QString("socket error:%1[%2]").arg(sckt->errorString()).arg(error));
}

void QEMqttObj::slotScktDisconnected()
{
    showMessage("server disconnected.");
    topicList.clear();
    if( !sckt ) return;
    disconnect_it(&broker);
    state = mqtt_disconnected;
    close_socket(&broker);
    state = mqtt_free;
}
