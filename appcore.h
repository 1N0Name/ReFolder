#ifndef APPCORE_H
#define APPCORE_H

#include <QObject>
#include <QDir>
#include <QDirIterator>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "googledrive.h"

class AppCore : public QObject
{
    Q_OBJECT
public:
    explicit AppCore(QObject * parent = nullptr);

    /* ------------------------- File System functions. ------------------------- */
    Q_INVOKABLE void createNewFolder(QString, QString) const;
    Q_INVOKABLE void createNewLink(QString, QString, QString) const;
    Q_INVOKABLE void renameItem(QString, QString) const;
    Q_INVOKABLE void removeItem(QString, bool) const;
    Q_INVOKABLE void makeFileHidden(QString) const;
    Q_INVOKABLE QString getFileBaseName(QString) const;
    Q_INVOKABLE QString getExtension(QString) const;
    /* -------------------------------------------------------------------------- */

    /* ---------------------------- Path & File info. --------------------------- */
    Q_INVOKABLE const QString savesPath() const;
    Q_INVOKABLE const QString normalizedSavesPath() const;
    Q_INVOKABLE QString getUrl(QString) const;
    Q_INVOKABLE QString getUrlFromLink(QString) const;
    /* -------------------------------------------------------------------------- */

    /* ------------------------------ GDrive func. ------------------------------ */
    void prepareItemListInJsonFile(QJsonDocument);
    GoogleDrive* getGoogleDrive();
    Q_INVOKABLE void auth();
    Q_INVOKABLE void uploadLinkList();
    Q_INVOKABLE void importFromGDrive();
    /* -------------------------------------------------------------------------- */

signals:
    void addPage(QString url, QString name);
    void goToBrowser();
    void goToHomePage();

private:
    inline QString normalizeFilePath(QString&) const;
    QString getFileUriPathNotation(QString) const;

    /* ------------------------------ GDrive func. ------------------------------ */
    QJsonArray getItemListArr(QDir);
    QJsonDocument getItemListInJson();
    void parseJsonObj(QDir, QJsonObject);
    /* -------------------------------------------------------------------------- */

private:
    QString m_savesPath = "file:///" + QDir::currentPath().left(1).toLower()
            + QDir::currentPath().remove(0 , 1) + "/saves";
    QString m_normalizedSavesPath = QDir::currentPath() + "/saves";
    GoogleDrive m_googleDrive;
    QString m_linkListFileName = "linkListFile.json";
};

#endif // APPCORE_H
