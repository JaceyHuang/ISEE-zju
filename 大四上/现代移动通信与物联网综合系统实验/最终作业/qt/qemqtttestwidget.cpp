#include "qemqtttestwidget.h"
#include "ui_qemqtttestwidget.h"
#include <QUuid>

QEmqttTestWidget::QEmqttTestWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::QEmqttTestWidget)
{
    ui->setupUi(this);
    emqttObj = new QEMqttObj(this);
    on.addFile(QString(":/icons/on.png"));
    off.addFile((QString(":/icons/off.png")));

    connect(emqttObj, SIGNAL(sigShowMessage(QString)), this, SLOT(slotMqttShowMessage(QString)));
    connect(emqttObj, SIGNAL(sigConnectError(QString)), this, SLOT(slotMqttConnectError(QString)));
    connect(emqttObj, SIGNAL(sigMessageArrived(QString,QByteArray)), this, SLOT(slotMqttMessageArrived(QString,QByteArray)));
    connect(emqttObj, SIGNAL(sigMessagePublished(QString,QByteArray)), this, SLOT(slotMqttMessagePublished(QString,QByteArray)));
    connect(emqttObj, SIGNAL(sigServerConnected()), this, SLOT(slotMqttServerConnected()));
    connect(emqttObj, SIGNAL(sigServerDisconnected()), this, SLOT(slotMqttServerDisconnected()));
    connect(emqttObj, SIGNAL(sigTopicSubscribed(QString)), this, SLOT(slotMqttTopicSubscribed(QString)));
    connect(emqttObj, SIGNAL(sigTopicUnSubscribed(QString)), this, SLOT(slotMqttTopicUnSubscribed(QString)));

    QSignalMapper *openButtonMapper;
    openButtonMapper = new QSignalMapper;

    QSignalMapper *closeButtonMapper;
    closeButtonMapper = new QSignalMapper;

    QLineEdit *pLineEdit[8] = {ui->lineEdit, ui->lineEdit_2, ui->lineEdit_3, ui->lineEdit_4, ui->lineEdit_5, ui->lineEdit_6, ui->lineEdit_7, ui->lineEdit_8};
    QPushButton *pOpenButton[7] = {ui->pushButton, ui->pushButton_3, ui->pushButton_5, ui->pushButton_7, ui->pushButton_9, ui->pushButton_11, ui->pushButton_13};
    QPushButton *pCloseButton[7] = {ui->pushButton_2, ui->pushButton_4, ui->pushButton_6, ui->pushButton_8, ui->pushButton_10, ui->pushButton_12, ui->pushButton_14};
    QPushButton *pStateButton[7] = {ui->stateButton, ui->stateButton_2, ui->stateButton_3, ui->stateButton_4, ui->stateButton_5, ui->stateButton_6, ui->stateButton_7};

    for (int i=0; i<8; i++){
        pLineEdit[i]->setEnabled(false);
    }

    for (int i=0; i<7; i++){
        pOpenButton[i]->setStyleSheet(QString("QPushButton:pressed{background-color:rgb(14 , 135 , 228);padding-left:3px;padding-top:3px;}"));
        connect(pOpenButton[i], SIGNAL(clicked()), openButtonMapper, SLOT(map()));
        openButtonMapper->setMapping(pOpenButton[i], i);

        pCloseButton[i]->setStyleSheet(QString("QPushButton:pressed{background-color:rgb(14 , 135 , 228);padding-left:3px;padding-top:3px;}"));
        connect(pCloseButton[i], SIGNAL(clicked()), closeButtonMapper, SLOT(map()));
        closeButtonMapper->setMapping(pCloseButton[i], i);

        pStateButton[i]->setEnabled(false);
//        pStateButton[i]->setIcon(off);
    }
    connect(openButtonMapper, SIGNAL(mapped(int)), this, SLOT(openButtonSlot(int)));
    connect(closeButtonMapper, SIGNAL(mapped(int)), this, SLOT(closeButtonSlot(int)));

    emqttObj->slotConnectServer("192.168.56.101", 1883, "", "");
    emqttObj->slotSubscribe("Trigger", 0);
}

QEmqttTestWidget::~QEmqttTestWidget()
{
    delete ui;
}

void QEmqttTestWidget::showMessage(QString sMsg, int device_id, int device_value, int device_value_2)
{
    if (sMsg != ""){
        ui->svrState->setText(sMsg);
    }
    switch (device_id) {
    case 30:
        ui->lineEdit_7->setText(device_value ? QString("True") : QString("False"));
        break;
    case 31:
        ui->lineEdit_8->setText(device_value ? QString("True") : QString("False"));
        break;
    case 40:
        ui->lineEdit->setText(QString("温度：%1 ℃，湿度：%2 %").arg(device_value).arg(device_value_2));
        break;
    case 41:
        ui->lineEdit_2->setText(QString("温度：%1 ℃，湿度：%2 %").arg(device_value).arg(device_value_2));
        break;
    case 42:
        ui->lineEdit_3->setText(QString("温度：%1 ℃，湿度：%2 %").arg(device_value).arg(device_value_2));
        break;
    case 43:
        ui->lineEdit_4->setText(QString("亮度：%1 Lux").arg(device_value));
        break;
    case 44:
        ui->lineEdit_5->setText(QString("亮度：%1 Lux").arg(device_value));
        break;
    case 45:
        ui->lineEdit_6->setText(QString("亮度：%1 Lux").arg(device_value));
        break;
    default:
        break;
    }
}

void QEmqttTestWidget::slotMqttShowMessage(QString msg)
{
    showMessage(QString("%1").arg(msg));
}

void QEmqttTestWidget::slotMqttServerConnected()
{
    showMessage(QString("服务器已成功连接！"));
}

void QEmqttTestWidget::slotMqttServerDisconnected()
{
    showMessage(QString("服务器已成功断开！"));
}

void QEmqttTestWidget::slotMqttConnectError(QString sError)
{
    showMessage(QString("出错信息: %1").arg(sError));
}

void QEmqttTestWidget::slotMqttTopicSubscribed(QString sTopic)
{
    showMessage(QString("已订阅主题-%1").arg(sTopic));
}

void QEmqttTestWidget::slotMqttTopicUnSubscribed(QString sTopic)
{
    showMessage(QString("取消订阅主题-%1").arg(sTopic));
}

void QEmqttTestWidget::slotMqttMessagePublished(QString sTopic, QByteArray payload)
{
    showMessage(QString("已发布消息：[%1]:%2").arg(sTopic).arg(QString::fromUtf8(payload)));
}

void QEmqttTestWidget::slotMqttMessageArrived(QString sTopic, QByteArray payload)
{
    int num[3] = {0};
    extract_int(QString::fromUtf8(payload), num);
    int device_id = num[0];
    int device_value = num[1];
    int device_value_2 = num[2];
    showMessage("", device_id, device_value, device_value_2);
}

void QEmqttTestWidget::openButtonSlot(int id){
    switch (id) {
    case 0:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 105, \"device_value\": 1}"), 0);
        ui->stateButton->setIcon(on);
        break;
    case 1:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 106, \"device_value\": 1}"), 0);
        ui->stateButton_2->setIcon(on);
        break;
    case 2:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 115, \"device_value\": 1}"), 0);
        ui->stateButton_3->setIcon(on);
        break;
    case 3:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 116, \"device_value\": 1}"), 0);
        ui->stateButton_4->setIcon(on);
        break;
    case 4:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 109, \"device_value\": 1}"), 0);
        ui->stateButton_5->setIcon(on);
        break;
    case 5:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 120, \"device_value\": 1}"), 0);
        ui->stateButton_6->setIcon(on);
        break;
    case 6:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 121, \"device_value\": 1}"), 0);
        ui->stateButton_7->setIcon(on);
        break;
    default:
        break;
    }
}

void QEmqttTestWidget::closeButtonSlot(int id){
    switch (id) {
    case 0:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 105, \"device_value\": 0}"), 0);
        ui->stateButton->setIcon(off);
        break;
    case 1:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 106, \"device_value\": 0}"), 0);
        ui->stateButton_2->setIcon(off);
        break;
    case 2:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 115, \"device_value\": 0}"), 0);
        ui->stateButton_3->setIcon(off);
        break;
    case 3:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 116, \"device_value\": 0}"), 0);
        ui->stateButton_4->setIcon(off);
        break;
    case 4:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 109, \"device_value\": 0}"), 0);
        ui->stateButton_5->setIcon(off);
        break;
    case 5:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 120, \"device_value\": 0}"), 0);
        ui->stateButton_6->setIcon(off);
        break;
    case 6:
        emqttObj->slotPublishString(QString("qt"), QString("{\"device_id\": 121, \"device_value\": 0}"), 0);
        ui->stateButton_7->setIcon(off);
        break;
    default:
        break;
    }
}

void QEmqttTestWidget::extract_int(QString payload, int num[]){
    int n = 0;
    QString temp;
    for (int i=0; i<payload.length(); i++){
        if (payload[i]>='0' && payload[i]<='9'){
            temp.append(payload[i]);
            if (payload[i+1]<'0' || payload[i+1]>'9'){
                num[n++] = temp.toInt();
                temp = "";
            }
        }
        if (num[0] < 100) {
            if (payload[i]=='t' && payload[i+1]=='r'){
                num[n++] = 1;
            }
            if (payload[i]=='f' && payload[i+1]=='a'){
                num[n++] = 0;
            }
        }
    }
}
