#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ClusterBackend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    ClusterBackend backend;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("clusterBackend", &backend);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}
