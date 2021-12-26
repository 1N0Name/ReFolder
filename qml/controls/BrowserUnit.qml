import QtQuick
import QtQuick.Window
import QtWebEngine
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "../."

Rectangle {
    id: window
    objectName: "appWin"
    color:                                                              Style.containerBackgroundColor

    /* ------------------------- Connection to AppCore. ------------------------- */
    Connections{
        target: appCore
    }
    /* -------------------------------------------------------------------------- */

    /* --------------------------- Global Properties. --------------------------- */
    property var qurl
    property string saveName
    /* -------------------------------------------------------------------------- */

    /* ---------------------------- Local Properties. --------------------------- */
    // Removes all .css files from the page.
    property string removeStyles:               "var elements = document.querySelectorAll('link[rel=stylesheet]');
                                                for (var i = 0; i < elements.length; i++) {
                                                    elements[i].parentNode.removeChild(elements[i]);
                                                }"
    // Turns on/off edit mode.
    property string turnOnReadingMode:          "document.querySelector('head').innerHTML += '<link rel=\"stylesheet\" href=\"../../css/styles.css\">';"

    // Turns on/off edit mode.
    property string turnOnEditMode:             "document.body.setAttribute('contenteditable', 'true');"
    property string turnOffEditMode:            "document.body.removeAttribute('contenteditable');"

    // Change Font Size.
    property string increaseFontSize:           "var selection = window.getSelection();
                                                if (selection) {
                                                    var size = window.getComputedStyle(selection.anchorNode.parentElement, null).getPropertyValue('font-size');
                                                    var newsize = Number(size.replace('px', ''));
                                                    newsize += 2;
                                                    document.execCommand('fontSize', false, '7');
                                                    var fontElements = document.getElementsByTagName('font');

                                                    for (var i = 0, len = fontElements.length; i < len; ++i) {
                                                        if (fontElements[i].size == '7') {
                                                            fontElements[i].removeAttribute('size');
                                                            fontElements[i].style.fontSize = newsize + 'px';
                                                        }
                                                    }
                                                }"
    property string decreaseFontSize:           "var selection = window.getSelection();
                                                 if (selection) {
                                                    var size = window.getComputedStyle(selection.anchorNode.parentElement, null).getPropertyValue('font-size');
                                                    var newsize = Number(size.replace('px', ''));
                                                    newsize -= 2;
                                                    document.execCommand('fontSize', false, '7');
                                                    var fontElements = document.getElementsByTagName('font');
                                                    for (var i = 0, len = fontElements.length; i < len; ++i) {
                                                        if (fontElements[i].size == '7') {
                                                            fontElements[i].removeAttribute('size');
                                                            fontElements[i].style.fontSize = newsize + 'px';
                                                        }
                                                    }
                                                }"
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                 Contol Menu                                */
    /* -------------------------------------------------------------------------- */
    ToolBar {
        id: mainMenu

        height:                                                         40

        anchors.right:                                                  parent.right
        anchors.left:                                                   parent.left
        anchors.top:                                                    parent.top
        anchors.margins:                                                0

        RowLayout {
            spacing: 5

            anchors.fill:                                               parent
            anchors.margins:                                            0
            
            // Save Page.
            CustomToolButton {
                id: savebtn
                btnIconSource:                                          "../../images/svg/fileSystem/download.svg"

                enabled:                                                appCore? appCore.getExtension(qurl) == "html" : false
//                enabled: webEngineView.action(WebEngineView.SavePage).enabled

                onClicked: {
                    webEngineView.action(WebEngineView.SavePage).trigger()
                }
            }

            // Divider.
            Rectangle {
                width:                                                  1
                height:                                                 20
                color:                                                  Style.disabled
            }

            // Remove all styles from Page.
            CustomToolButton {
                btnIconSource:                                          "../../images/svg/browser/raw.svg"

                onClicked: {
                    webEngineView.runJavaScript(removeStyles)
                }
            }

            // Read Mode styles.
            CustomToolButton {
                btnIconSource:                                          "../../images/svg/browser/readingMode.svg"

                onClicked: {
                    webEngineView.runJavaScript(turnOnReadingMode)
                }
            }

            // Divider.
            Rectangle {
                width:                                                  1
                height:                                                 20
                color:                                                  Style.disabled
            }

            // Turn on/off edit mode.
            Switch {
                id: controlSwitch
                text: "Edit mode"

                property bool flag: false

                indicator: Rectangle {
                    implicitWidth:                                      40
                    implicitHeight:                                     20
                    radius:                                             20

                    x:                                                  controlSwitch.leftPadding
                    y:                                                  parent.height / 2 - height / 2

                    color:                                              controlSwitch.checked ? Style.primaryColor : Style.disabled

                    Rectangle {
                        x:                                              controlSwitch.checked ? parent.width - width - 4 : 4
                        y:                                              parent.height / 2 - height / 2

                        width:                                          15
                        height:                                         15
                        radius:                                         15

                        color:                                          controlSwitch.down ? "#ccc" : "#fff"
                    }
                }

                contentItem: Text {
                    text:                                               parent.text

                    color:                                              Style.highEmphasis
                    font.family :                                       Style.fontName
                    font.pointSize:                                     Style.fontSize

                    leftPadding:                                        parent.indicator.width + parent.spacing
                    verticalAlignment:                                  Text.AlignVCenter
                }

                onCheckedChanged: {
                    flag = checked

                    if(flag == false) {
                        webEngineView.runJavaScript(turnOffEditMode)
                    } else {
                        webEngineView.runJavaScript(turnOnEditMode)
                    }
                }
            }

            // Increase font size.
            CustomToolButton {
                btnIconSource:                                          "../../images/svg/browser/font-increase.svg"

                onClicked: {
                    webEngineView.runJavaScript(increaseFontSize)
                }
            }

            // Decrease font size.
            CustomToolButton {
                btnIconSource:                                          "../../images/svg/browser/font-decrease.svg"

                onClicked: {
                    webEngineView.runJavaScript(decreaseFontSize)
                }
            }

            // Bold.
            CustomToolButton {
                btnIconSource:                                          "../../images/svg/browser/bold.svg"

                onClicked: {
                    webEngineView.action(WebEngineView.ToggleBold).trigger()
                }
            }

            // Divider.
            Rectangle {
                width:                                                  1
                height:                                                 20
                color:                                                  Style.disabled
            }

            // Path to source.
            TextField {
                id: fileURL
                text: webEngineView.url

                readOnly:                                               true

                Layout.fillWidth:                                       true
                Layout.preferredHeight:                                 30

                color:                                                  "#fff"
                font.family:                                            Style.fontName
                font.pointSize:                                         Style.fontSize
                verticalAlignment:                                      Text.AlignVCenter
                selectByMouse:                                          true

                background: Rectangle {
                    color:                                              Style.pageBackgroundColor

                    border.color:                                       Style.disabled
                    border.width:                                       1
                    radius:                                             5

                    anchors.fill:                                       parent
                }
            }
        }

        background: Rectangle {
            color: Style.containerBackgroundColor

            anchors.fill: parent
        }
    }
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                 WebEngine.                                 */
    /* -------------------------------------------------------------------------- */
    WebEngineView {
        id: webEngineView
        url:                                                            appCore? appCore.getUrl(qurl) : ""
        
        // New profile for each created page.
        profile: WebEngineProfile{}

        anchors.left:                                                   parent.left
        anchors.right:                                                  parent.right
        anchors.bottom:                                                 parent.bottom
        anchors.top:                                                    mainMenu.bottom
        anchors.rightMargin:                                            6

        Component.onCompleted: {
            profile.downloadRequested.connect(function(download) {
                download.downloadFileName = saveName;
                download.downloadDirectory = appCore.normalizedSavesPath();
                download.savePageFormat = WebEngineDownloadRequest.CompleteHtmlSaveFormat;
                download.accept();
            })

            profile.onDownloadFinished.connect(function(checkDownload) {
                console.log("File Saved.");
            })
        }

        onContextMenuRequested: function(request) {
            request.accepted = true;
        }
    }
    /* -------------------------------------------------------------------------- */
}
