#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QIcon>

#include "appcore.h"

#define PR_DEBUG 0

int main(int argc, char *argv[])
{
    /* --------------------------- Turning on OpenGL. --------------------------- */
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    /* -------------------------------------------------------------------------- */
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

/* ------------------------ Turn on/off QML logging. ------------------------ */
#if PR_DEBUG == 0
    QLoggingCategory::setFilterRules("*.debug=false\n"
                                     "*.info=false\n"
                                     "*.warning=false\n"
                                     "*.critical=true");
    fprintf(stderr, "Disabling QML logging in release build.\n");
#else
    fprintf(stderr, "QML logging enabled.\n");
#endif
/* -------------------------------------------------------------------------- */

    /* ----------------------- Connecting AppCore to Qml. ----------------------- */
    AppCore appCore;
    engine.rootContext()->setContextProperty("appCore", &appCore);
    /* -------------------------------------------------------------------------- */

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
