import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Dialogs
import QtWebEngine

import "../controls"
import "../."

Rectangle {
    id: background
    color:                                                          Style.pageBackgroundColor
    radius:                                                         10

    /* -------------------- Internal properties / functions. -------------------- */
    QtObject {
        id: internal

        // Path to "saves" folder, where all links and  web pages are hold.
        property string savesPath:                                  appCore? appCore.savesPath() : null

        // Properties of current active file.
        property var currentSelectedItemURL
        property var currentSelectedItemName
        property var currentSelectedItemStatus

        function loadingChanged(){
            if(!swebEngineView.loading){
                swebEngineView.saveName = appCore.getFileBaseName(currentSelectedItemName) + '.html';
                swebEngineView.action(WebEngineView.SavePage).trigger();
            }
        }
    }
    /* -------------------------------------------------------------------------- */

    /* ------------------------- Connection to AppCore. ------------------------- */
    Connections {
        target: appCore
    }
    /* -------------------------------------------------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Control Panel                               */
    /* -------------------------------------------------------------------------- */

    /* --------------- Dialogue for adding new item (folder/link). -------------- */
    CustomInputDialog {
       id: objectAddDialog
       hasSecondInputField: true
       headerText: "Add New Item"

       x: (background.width / 2) - (objectAddDialog.width / 2)
       y: (background.height / 2) - (objectAddDialog.height / 2)

       onAccepted: {
           appCore.createNewLink(folderModel.folder, firstFieldText, secondFieldText)
       }

       onApplied: {
           appCore.createNewFolder(folderModel.folder, firstFieldText)
       }
    }
    /* -------------------------------------------------------------------------- */

    /* ---------------- Control buttons (Go Back, New Item, Sort) --------------- */
    Row {
        id: controlMenu
        spacing: 5

        anchors.top:                                                parent.top
        anchors.left:                                               parent.left
        anchors.topMargin:                                          5
        anchors.leftMargin:                                         10

        FileMenuBtn {
            id: leftArrowButton
            btnIconSource:                                          "../../images/svg/fileSystem/left-arrow.svg"

            onClicked: {
                if (folderModel.folder != internal.savesPath) {
                    folderModel.folder = folderModel.parentFolder
                }
            }
        }

        FileMenuBtn {
            id: dirAddButton
            btnIconSource:                                          "../../images/svg/fileSystem/add.svg"

            onClicked: {
                objectAddDialog.open()
            }
        }

        FileMenuBtn {
            id: filterBtn
            btnIconSource:                                          "../../images/svg/fileSystem/sort_btn.svg"

            onClicked: {
                filterMenu.popup()
            }
        }
    }
    /* -------------------------------------------------------------------------- */

    /* ---------------------------- File Filter Menu. --------------------------- */
    CustomMenu {
        id: filterMenu

        menuWidth:                                                  120

        hasRadioButton:                                             true
        currentActive:                                              1
        hasIcon:                                                    false

        Action {
            id: unsortFilterBtn
            text: qsTr("Unsorted")
            icon.source:                                            "../../images/svg/fileSystem/rename.svg"

            onTriggered: {
                folderModel.sortField = "Unsorted"
            }
        }

        Action {
            id: nameFilterBtn
            text: qsTr("Name")
            icon.source:                                            "../../images/svg/fileSystem/rename.svg"

            onTriggered: {
                folderModel.sortField = "Name"
            }
        }

        Action {
            id: timeFilterBtn
            text: qsTr("Time")
            icon.source:                                            "../../images/svg/fileSystem/rename.svg"

            onTriggered: {
                folderModel.sortField = "Time"
            }
        }
    }
    /* -------------------------------------------------------------------------- */

    /* ------------------------------ Search Field. ----------------------------- */
    TextField {
        id: searchField

        width:                                                      250
        height:                                                     30

        color:                                                      "#fff"
        font.family:                                                Style.fontName
        font.pointSize:                                             Style.fontSize
        verticalAlignment:                                          Text.AlignVCenter
        selectByMouse:                                              true

        leftPadding:                                                textFieldIcon.anchors.leftMargin * 3 + textFieldIcon.width + 1.01
        anchors.right:                                              parent.right
        anchors.top:                                                parent.top
        anchors.rightMargin:                                        10
        anchors.topMargin:                                          5

        // Placeholder text.
        Text {
            text:                                                   qsTr("Enter your search term...")
            visible:                                                !searchField.text && !searchField.activeFocus

            color:                                                  Style.disabled
            font.family:                                            Style.fontName
            font.pointSize:                                         Style.fontSize

            anchors.top:                                            parent.top
            anchors.bottom:                                         parent.bottom
            anchors.left:                                           textFieldDelimeter.right
            anchors.leftMargin:                                     5
            verticalAlignment:                                      Text.AlignVCenter
        }

        Image {
            id: textFieldIcon
            source: "../../images/svg/fileSystem/search.svg"
            antialiasing: true

            width:                                                  20
            height:                                                 20
            sourceSize.width:                                       20
            sourceSize.height:                                      20
            fillMode:                                               Image.PreserveAspectFit

            anchors.left:                                           parent.left
            anchors.leftMargin:                                     (searchField.height - textFieldIcon.width) / 2
            anchors.verticalCenter:                                 parent.verticalCenter
        }
        
        // Delimeter.
        Rectangle {
            id: textFieldDelimeter
            width:                                                  1
            height:                                                 searchField.height
            color:                                                  Style.disabled

            anchors.left:                                           parent.left
            anchors.leftMargin:                                     textFieldIcon.width + textFieldIcon.anchors.leftMargin * 2
        }

        ColorOverlay {
            anchors.fill:                                           textFieldIcon
            source:                                                 textFieldIcon
            color:                                                  "#fff"
            antialiasing:                                           false
        }

        background: Rectangle {
            color:                                                  Style.transparent
            radius:                                                 5
            border.width:                                           1
            border.color:                                           Style.disabled
        }

        // Filter.
        onTextChanged: {
            folderModel.nameFilters = ["*" + searchField.text + "*"]
        }
    }
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                 File System                                */
    /* -------------------------------------------------------------------------- */
    ListView {
        id: folderField
        clip: false
        spacing:                                                    5

        anchors.left:                                               parent.left
        anchors.right:                                              parent.right
        anchors.top:                                                controlMenu.bottom
        anchors.bottom:                                             parent.bottom
        anchors.margins:                                            10

        FolderListModel {
            id: folderModel

            showDirs:                                               true
            showDirsFirst:                                          true
            folder:                                                 internal.savesPath
            nameFilters:                                            ["*.*"]
        }

        // Delegate items (file / dirs).
        Component {
            id: fileDelegate

            Button {
                id: btnDelegate
                flat: true

                property color dynamicColorBtn: if(btnDelegate.down) {
                                                    btnDelegate.down ? Style.btnColorClicked : Style.btnColorDefault
                                                } else {
                                                    btnDelegate.hovered ? Style.btnColorActive : Style.btnColorDefault
                                                }

                width: folderField.width
                height: 30

                background: Rectangle {
                    id: fileDelegateBg
                    radius:                                         5

                    color:                                          dynamicColorBtn
                }

                Image {
                    id: folderIcon
                    source: appCore? fileIsDir? "../../images/svg/fileSystem/folder.svg" : (appCore.getExtension(fileName) == "html")?
                                                    "../../images/svg/fileSystem/html.svg" : "../../images/svg/fileSystem/url.svg" : ""
                    antialiasing: true

                    width:                                          15
                    height:                                         15
                    sourceSize.width:                               15
                    sourceSize.height:                              15
                    fillMode:                                       Image.PreserveAspectFit

                    anchors.left:                                   parent.left
                    anchors.leftMargin:                             10
                    anchors.verticalCenter:                         parent.verticalCenter
                }

                ColorOverlay {
                    visible: fileIsDir ? false : true

                    anchors.fill:                                   folderIcon
                    source:                                         folderIcon
                    color:                                          "#fff"
                    antialiasing:                                   false
                }

                contentItem: Text {
                    id: folderDelegateText

                    text:                                           appCore? appCore.getFileBaseName(fileName) : null
                    color:                                          "#fff"
                    font.family:                                    Style.fontName
                    font.pointSize:                                 Style.fontSize
                    verticalAlignment:                              Text.AlignVCenter

                    anchors.left:                                   folderIcon.right
                    anchors.leftMargin:                             10
                }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent

                    acceptedButtons: Qt.RightButton

                    onClicked: {
                        internal.currentSelectedItemURL = fileUrl
                        internal.currentSelectedItemName = fileName
                        internal.currentSelectedItemStatus = fileIsDir

                        contextMenu.popup()
                    }
                }

                /* ------------- Functionality of moving items between folders. ------------- */
                
                /* -------------------------------------------------------------------------- */

                onClicked: {
                    if(fileIsDir) {
                        folderModel.folder = fileURL
                    } else {
                        appCore.goToBrowser()
                        appCore.addPage(fileURL, appCore.getFileBaseName(fileName));
                    }
                }
            }
        }

        model: folderModel
        delegate: fileDelegate
    }
    /* -------------------------------------------------------------------------- */

    
    /* --------------------------- File Rename Dialog. -------------------------- */
    CustomInputDialog {
        id: objectRenameDialog
        hasSecondInputField: false

        x: background.width / 2 - objectRenameDialog.width / 2
        y: background.height / 2 - objectRenameDialog.height / 2

        headerText: "Rename Item"
        phFirstText: "Enter new name..."
        firstBtnName: "Save"

        onApplied: {
            appCore.renameItem(internal.currentSelectedItemURL, firstFieldText)
        }
    }
    /* -------------------------------------------------------------------------- */

    /* --------------------- File interaction context menu. --------------------- */
    CustomMenu {
        id: contextMenu

        Action {
            id: renameAction
            text: qsTr("Rename")
            icon.source:                                            "../../images/svg/fileSystem/rename.svg"

            onTriggered: {
                objectRenameDialog.open()
            }
        }

        Action {
            id: removeAction
            text: qsTr("Delete")
            icon.source:                                            "../../images/svg/fileSystem/remove.svg"

            onTriggered: {
                appCore.removeItem(internal.currentSelectedItemURL, internal.currentSelectedItemStatus)
            }
        }

        /* ------- Control over the absence/presence of the "Download" option. ------ */
        onOpened: {
            if (contextMenu.count == 2 && appCore.getExtension(internal.currentSelectedItemName) == "txt") {
                contextMenu.addAction(Qt.createQmlObject('
                import QtQuick.Controls 2.15
                import QtWebEngine

                Action {
                    id: downloadAction
                    text: qsTr("Download")
                    icon.source:                                    "../../images/svg/fileSystem/download.svg"

                    onTriggered: {
                        swebEngineView.url = "' + appCore.getUrlFromLink(internal.currentSelectedItemURL) + '"
                    }
                }', contextMenu))
            }
            if (contextMenu.count == 3 && !(appCore.getExtension(internal.currentSelectedItemName) == "txt")) {
                contextMenu.removeAction(contextMenu.actionAt(2))
            }
        }
    }
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                  WebEngine                                 */
    /* -------------------------------------------------------------------------- */

    /* -------------------- Custom Profile for New Instance. -------------------- */
    WebEngineProfile {
        id: privateProfile
    }
    /* -------------------------------------------------------------------------- */

    /* ---------- New "tab" for downloading a web page from .txt file. ---------- */
    WebEngineView {
        id: swebEngineView
        profile: privateProfile

        property string saveName

        Component.onCompleted: {
            privateProfile.downloadRequested.connect(function(download) {
                download.downloadFileName = saveName;
                download.downloadDirectory = appCore.normalizedSavesPath();
                download.savePageFormat = WebEngineDownloadRequest.CompleteHtmlSaveFormat;
                download.accept();
            })

            privateProfile.onDownloadFinished.connect(function(checkDownload) {
                console.log("File downloaded.");
                appCore.makeFileHidden(internal.currentSelectedItemURL)
            })
        }

        onLoadingChanged: {
            internal.loadingChanged();
        }
    }
    /* -------------------------------------------------------------------------- */
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:1}D{i:2}D{i:4}D{i:5}D{i:3}D{i:7}D{i:8}
D{i:9}D{i:6}D{i:12}D{i:13}D{i:11}D{i:20}
}
##^##*/
