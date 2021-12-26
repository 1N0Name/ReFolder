#include "appcore.h"

#include <QDebug>
#include <QFile>
#include <windows.h>

#define PR_DEBUG == 1

/* -------------------------------------------------------------------------- */
/*                                Public func.                                */
/* -------------------------------------------------------------------------- */
AppCore::AppCore(QObject *parent) : QObject(parent)
{

}

/* ------------------------- File System functions. ------------------------- */
void AppCore::createNewFolder(QString filePath, QString name) const
{
    if (name.isEmpty()) {
        qDebug() << "Empty Field";
        return;
    }

    normalizeFilePath(filePath);
    QDir().mkdir(filePath + "/" + name);
}

void AppCore::createNewLink(QString filePath, QString fileName, QString url) const
{
    if (fileName.isEmpty() || url.isEmpty()) {
        qDebug() << "Empty Field";
        return;
    }

    normalizeFilePath(filePath);
    QFile file(filePath + "/" + fileName + ".txt");
    if(!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;

    QTextStream outStream(&file);
    outStream << url << "\n";
    file.close();
}

void AppCore::renameItem(QString filePath, QString newName) const
{
    normalizeFilePath(filePath);
    if(QFileInfo(filePath).isDir()) {
        QDir().rename(filePath, filePath.left(filePath.lastIndexOf("/") + 1) + newName);
    } else {
        QFile::rename(filePath, filePath.left(filePath.lastIndexOf("/") + 1) +
                      newName + filePath.right(filePath.size() - filePath.lastIndexOf(".")));
    }
}

void AppCore::removeItem(QString filePath, bool isFolder) const
{
    normalizeFilePath(filePath);

    if(isFolder) {
        QDir(filePath).removeRecursively();
    } else {
        QFile::remove(filePath);
    }
}

void AppCore::makeFileHidden(QString filePath) const
{
    normalizeFilePath(filePath);

    LPCWSTR txtFile = (const wchar_t*) filePath.utf16();;
    qDebug() << txtFile;
    SetFileAttributesW (
                txtFile,
                FILE_ATTRIBUTE_HIDDEN
                );

    LPCWSTR assetsDir = (const wchar_t*)(filePath.left(filePath.lastIndexOf(".")) + "_files").utf16();
    qDebug() << assetsDir;
    if(QDir(filePath.left(filePath.lastIndexOf(".")) + "_files").exists()) {
        SetFileAttributesW (
                    assetsDir,
                    FILE_ATTRIBUTE_HIDDEN
                    );
    }
}

QString AppCore::getFileBaseName(QString fileName) const
{
    return fileName.left(fileName.lastIndexOf("."));
}

QString AppCore::getExtension(QString fileName) const
{
    return fileName.mid(fileName.lastIndexOf(".") + 1, fileName.size());
}
/* -------------------------------------------------------------------------- */

/* ---------------------------- Path & File info. --------------------------- */
const QString AppCore::savesPath() const
{
    return m_savesPath;
}

const QString AppCore::normalizedSavesPath() const
{
    return m_normalizedSavesPath;
}

QString AppCore::getUrl(QString filePath) const
{
    if(getExtension(filePath) == "html")
        return getFileUriPathNotation(filePath);
    else
        return getUrlFromLink(filePath);
}

QString AppCore::getUrlFromLink(QString filePath) const
{
    normalizeFilePath(filePath);
    QFile file(filePath);
    file.open(QIODevice::ReadOnly);

    QTextStream in(&file);
    QString url = in.readLine();
    return url;
}
/* -------------------------------------------------------------------------- */

/* ------------------------------ GDrive func. ------------------------------ */
void AppCore::prepareItemListInJsonFile(QJsonDocument doc)
{
    QFile file(this->m_linkListFileName);
    file.open(QFile::WriteOnly);

    file.write(doc.toJson());

    file.close();
}

GoogleDrive *AppCore::getGoogleDrive()
{
    return &(this->m_googleDrive);
}

void AppCore::auth()
{
    this->m_googleDrive.auth();
}

void AppCore::uploadLinkList()
{
    prepareItemListInJsonFile(getItemListInJson());
    QFile file(this->m_linkListFileName);
    file.open(QFile::ReadOnly);

    QByteArray data = file.readAll();

    if (this->m_googleDrive.getFileListMap()->count(this->m_linkListFileName) > 0) {
        this->m_googleDrive.updateFile(this->m_linkListFileName, data);
    } else {
        this->m_googleDrive.uploadFile(this->m_linkListFileName, data);
    }
    file.close();
}

void AppCore::importFromGDrive()
{
    QDir dir("saves");
    QDir defDir;

    this->m_googleDrive.downloadFile(defDir, this->m_linkListFileName);

    QJsonDocument doc;
    QFile file(this->m_linkListFileName);
    file.open(QFile::ReadOnly);
    doc = QJsonDocument().fromJson(file.readAll());
    file.close();

    auto docObj = doc.object();
    QJsonArray arr = docObj["items"].toArray();

    for (int i = 0; i < arr.size(); ++i) {
        QJsonObject obj = arr[i].toObject();
        this->parseJsonObj(dir, obj);
    }
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*                                Private func.                               */
/* -------------------------------------------------------------------------- */
inline QString AppCore::normalizeFilePath(QString& filePath) const
{
    return  filePath.remove(0, 8);;
}

QString AppCore::getFileUriPathNotation(QString filePath) const
{
    return filePath.replace(" ", "%20");
}

/* ------------------------------ GDrive func. ------------------------------ */
QJsonArray AppCore::getItemListArr(QDir dir)
{
    QJsonArray arr;

    QFileInfoList list = dir.entryInfoList();

    for (int i = 0; i < list.size(); ++i) {
        QFileInfo fileInfo = list.at(i);

        if (fileInfo.fileName() == "" || fileInfo.fileName() == "." || fileInfo.fileName() == "..") {
            continue;
        }

        QJsonObject obj;
        obj.insert("name", fileInfo.fileName());

        if (QFileInfo(fileInfo.filePath()).isDir()) {
            obj.insert("items", getItemListArr(fileInfo.filePath()));
            arr.push_back(obj);
        } else if (fileInfo.completeSuffix() == "txt") {
            QFile file(fileInfo.filePath());
            file.open(QFile::ReadOnly);
            obj.insert("link", QString(file.readLine()));
            file.close();
            arr.push_back(obj);
        }
    }

    return arr;
}

QJsonDocument AppCore::getItemListInJson()
{
    QJsonDocument doc;

    QDir dir("saves");

    QJsonObject mainObj;
    mainObj.insert("name", "itemList");
    mainObj.insert("items", getItemListArr(dir));
    doc.setObject(mainObj);

    return doc;
}

void AppCore::parseJsonObj(QDir dir, QJsonObject obj)
{
    QJsonValue name = obj["name"];

    if (obj["items"].isNull()) {
        QJsonValue link = obj["link"];
        QFile file(dir.path() + "/" + name.toString());
        file.open(QFile::WriteOnly);
        QTextStream txtStream(&file);
        txtStream << link.toString();
        file.close();
    } else {
        QDir().mkdir(dir.path() + "/" + name.toString());
        QJsonArray arr = obj["items"].toArray();

        for (int i = 0; i < arr.size(); ++i) {
            QJsonObject locObj = arr[i].toObject();
            this->parseJsonObj(dir.path() + "/" + name.toString(), locObj);
        }
    }
}
/* -------------------------------------------------------------------------- */
