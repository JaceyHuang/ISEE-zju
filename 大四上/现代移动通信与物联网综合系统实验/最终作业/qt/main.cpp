#include "qemqtttestwidget.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QEmqttTestWidget w;
    w.show();

    return a.exec();
}
