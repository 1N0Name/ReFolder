#include "googledrive.h"
#include <QHttpPart>
#include <QDir>

GoogleDrive::GoogleDrive(QObject *parent) :
    QObject(parent),
    reply( ),
    req( new QNetworkRequest ),
    manager(new QNetworkAccessManager( this ))
{
    isAuth = false;
    google = new QOAuth2AuthorizationCodeFlow(this);
    google->setScope("https://www.googleapis.com/auth/drive");

    connect(google, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, [=](QUrl url) {
           QUrlQuery query(url);
           query.addQueryItem("prompt", "consent");      // Param required to get data everytime
           query.addQueryItem("access_type", "offline"); // Needed for Refresh Token (as AccessToken expires shortly)
           url.setQuery(query);

           QDesktopServices::openUrl(url);
       });

    QFile jsonFile(QDir::currentPath() + "/jsonFile.json");
    jsonFile.open(QFile::ReadOnly);
    QJsonDocument document;
    document = QJsonDocument().fromJson(jsonFile.readAll());
    jsonFile.close();

    const auto object = document.object();
    const auto settingsObject = object["web"].toObject();
    const QUrl authUri(settingsObject["auth_uri"].toString());
    const auto clientId = settingsObject["client_id"].toString();
    const QUrl tokenUri(settingsObject["token_uri"].toString());
    const auto clientSecret(settingsObject["client_secret"].toString());
    const auto redirectUris = settingsObject["redirect_uris"].toArray();
    const QUrl redirectUri(redirectUris[0].toString()); // Get the first URI
    const auto port = static_cast<quint16>(redirectUri.port()); // Get the port

    google->setAuthorizationUrl(authUri);
    google->setClientIdentifier(clientId);
    google->setAccessTokenUrl(tokenUri);
    google->setClientIdentifierSharedKey(clientSecret);

    google->setModifyParametersFunction([](QAbstractOAuth::Stage stage, QMultiMap<QString, QVariant> *parameters)
    {
       if (stage == QAbstractOAuth::Stage::RequestingAccessToken) {
          QByteArray code = parameters->value("code").toByteArray();
          (*parameters).key("code") = QUrl::fromPercentEncoding(code);
       }
    });

    auto replyHandler = new QOAuthHttpServerReplyHandler(port, this); //port, this?
    google->setReplyHandler(replyHandler);
}

void GoogleDrive::auth()
{
    google->grant();

    QObject::connect(google, &QOAuth2AuthorizationCodeFlow::granted, this, &GoogleDrive::accessGrantedRep);
    QObject::connect(google, &QOAuth2AuthorizationCodeFlow::granted, this, &GoogleDrive::grantedAuth);
}

void GoogleDrive::grantedAuth()
{
    //emit succAuthSign();
    getFileList();
    isAuth = true;
}

bool GoogleDrive::isAuthFun()
{
    return isAuth;
}

QMap<QString, QString> *GoogleDrive::getFileListMap()
{
    return &(this->fileList);
}

void GoogleDrive::accessGrantedRep()
{
    qDebug() << "Access Granted! Token is " << google->token();
}

void GoogleDrive::readReply()
{
    qDebug() << "answer:" << reply->readAll();
}

void GoogleDrive::getFileList()
{
    this->fileList.clear();

    QFile jsonFile("GDFileList.json");
    jsonFile.open(QFile::WriteOnly | QIODevice::Text);
    QJsonDocument document;

    QUrl url("https://www.googleapis.com/drive/v2/files");
    req->setUrl(url);
    QString headerData = "Bearer " + google->token();
    req->setRawHeader("Authorization", headerData.toLatin1());

    reply = manager->get(*req);
    QTextStream txtStr(&jsonFile);

    // Wait till the response is completed
    while (!reply->isFinished()) {
        QCoreApplication::processEvents();
    }

    txtStr << reply->readAll();
    jsonFile.close();

    jsonFile.open(QFile::ReadOnly | QIODevice::Text);
    QString fileVal = jsonFile.readAll();
    jsonFile.close();
    document = QJsonDocument::fromJson(fileVal.toUtf8());
    auto object = document.object();
    QJsonArray jsonArray = object["items"].toArray();

    foreach (const QJsonValue &value, jsonArray)
    {
        if (value.isObject())
        {
            QJsonObject obj = value.toObject();
            QString title = obj["title"].toString();
            QString id = obj["id"].toString();

            fileList[title] = id;
        }
    }

    cleanNetVars();
}

void GoogleDrive::downloadFile(QDir dir, QString fileName)
{
    qDebug() << "Downloading file...";
    if (!isAuth) {
        qDebug() << "No auth";
        return;
    }

    getFileList();
    // Get FileID
    QString FileID = fileList.value(fileName, QString());
    qDebug() << FileID;

    if (FileID == "") {
        QString msg = "Такого файла не существует!";
        qDebug() << "Такого файла не существует!";

        return;
    }

    // Now Prepare the request
    QUrl url(tr("https://www.googleapis.com/drive/v3/files/%1").arg(FileID));
    QUrlQuery query;
    query.addQueryItem("alt", "media");
    url.setQuery(query.query());

    req->setUrl(url);

    QString headerData = "Bearer " + google->token();
    req->setRawHeader("Authorization", headerData.toLocal8Bit());

    reply = manager->get(*req);

    while (!reply->isFinished()) {
        QCoreApplication::processEvents();
    }

    QByteArray array = reply->readAll();
    QFile file(dir.path() + "/" + fileName);
    file.open(QFile::WriteOnly | QIODevice::Text);
    QTextStream txtStr(&file);
    txtStr << array;
    file.close();

    QString msg;
    msg = "Файл был успешно получен."; //сделать по reply
    qDebug() << "Файл был успешно получен.";

    cleanNetVars();
}

QHttpPart GoogleDrive::prepareMetadataPart(QString fileName)
{
    QHttpPart MetadataPart;
    MetadataPart.setRawHeader("Content-Type", "application/json; charset=UTF-8");
    QString Body;
    Body = "{\n"
           + tr("\"name\": \"%1\"\n").arg(fileName)
           + tr("}");
    MetadataPart.setBody(Body.toUtf8());

    return MetadataPart;
}

QHttpMultiPart* GoogleDrive::prepareMultiPart(QString boundary, QHttpPart metadataPart, QHttpPart mediaPart)
{
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::RelatedType);
    multiPart->setBoundary("bound");
    multiPart->append(metadataPart);
    multiPart->append(mediaPart);

    return multiPart;
}

void GoogleDrive::cleanNetVars()
{
    this->req = new QNetworkRequest();
    this->manager = new QNetworkAccessManager();
}

void GoogleDrive::uploadFile(QString fileName, QByteArray rawData)
{
    if (!isAuth) {
        qDebug() << "No auth";
        return;
    }

    getFileList();

    cleanNetVars();

    QString auth = google->token();
    auth = "Bearer " + auth;

    // Prepare MetadataPart
    QHttpPart MetadataPart = this->prepareMetadataPart(fileName);

    // Prepare MediaPart
    QHttpPart MediaPart;
    //MediaPart.setRawHeader("Content-Type", "text/plain");
    MediaPart.setRawHeader("Content-Type", "application/json");
    MediaPart.setBody(rawData);

    // Now add MetaDataPart and MediaPart together to form multiPart
    QHttpMultiPart *multiPart = prepareMultiPart("bound", MetadataPart, MediaPart);

    QUrl url("https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart");
    req->setUrl(url);
    req->setRawHeader("Content-Type", "multipart/related; boundary=bound");
    req->setRawHeader("Authorization", auth.toLatin1());

    reply = manager->post(*req, multiPart);

    QString msg;
    msg = "Файл был успешно отправлен."; //сделать по reply
}

void GoogleDrive::updateFile(QString fileName, QString rawData) //исправить неоднозначность апдейта файла
{
    getFileList();
    cleanNetVars();

    QString auth = google->token();
    auth = "Bearer " + auth;

    QUrl url("https://www.googleapis.com/upload/drive/v3/files/" +
             this->fileList[this->fileList.find(fileName).key()] + "?uploadType=media");
    req->setUrl(url);
    req->setRawHeader("Content-Type", "application/json");
    req->setRawHeader("Authorization", auth.toLatin1());

    reply = manager->sendCustomRequest(*req, "PATCH", rawData.toUtf8());
}

GoogleDrive::~GoogleDrive()
{
    delete google;
    delete reply;
    delete req;
    delete manager;
}
