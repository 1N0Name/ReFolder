#ifndef GOOGLEDRIVE_H
#define GOOGLEDRIVE_H

#include <QOAuth2AuthorizationCodeFlow>
#include <QFile>
#include <QJsonDocument>
#include <QDesktopServices>
#include <QOAuthHttpServerReplyHandler>
#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QMap>
#include <QTimer>
#include <QCoreApplication>
#include <QHttpPart>

class GoogleDrive : public QObject
{
Q_OBJECT
private:
    QOAuth2AuthorizationCodeFlow *google;
    QNetworkReply *reply;
    QNetworkRequest *req;
    QNetworkAccessManager *manager;
    QString token;
    QMap<QString, QString> fileList;
    bool isAuth;

    QHttpPart prepareMetadataPart(QString fileName);
    QHttpMultiPart* prepareMultiPart(QString boundary, QHttpPart metadataPart, QHttpPart mediaPart);
    void cleanNetVars();
    void getFileList();
    void readReply();
    void accessGrantedRep();

public:
    GoogleDrive(QObject *parent=nullptr);
    void uploadFile(QString fileName, QByteArray rawData = "");
    void downloadFile(QDir dir, QString fileName);
    void updateFile(QString fileName, QString rawData = "");
    bool isAuthFun();
    QMap<QString, QString>* getFileListMap();
    ~GoogleDrive();

signals:


public slots:
    void auth();
    void grantedAuth();
};

#endif // GOOGLEDRIVE_H

