#ifndef QEMQTTTESTWIDGET_H
#define QEMQTTTESTWIDGET_H

#include <QWidget>
#include <QDebug>
#include <QSignalMapper>
#include <QPushButton>
#include "qemqttobj.h"

namespace Ui {
class QEmqttTestWidget;
}

class QEmqttTestWidget : public QWidget
{
    Q_OBJECT

    QEMqttObj *emqttObj;
public:
    explicit QEmqttTestWidget(QWidget *parent = nullptr);
    ~QEmqttTestWidget();
    void extract_int(QString payload, int num[]);

protected:
    void showMessage(QString sMsg, int device_id=0, int device_value=0, int device_value_2=0);
private:
    Ui::QEmqttTestWidget *ui;
    QIcon on, off;

private slots:
    void slotMqttShowMessage(QString msg);
    void slotMqttServerConnected();
    void slotMqttServerDisconnected();
    void slotMqttConnectError(QString sError);
    void slotMqttTopicSubscribed(QString sTopic);
    void slotMqttTopicUnSubscribed(QString sTopic);
    void slotMqttMessagePublished(QString sTopic,QByteArray payload);
    void slotMqttMessageArrived(QString sTopic,QByteArray payload);

    void openButtonSlot(int id);
    void closeButtonSlot(int id);
};

#endif // QEMQTTTESTWIDGET_H
