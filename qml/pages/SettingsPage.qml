import QtQuick 2.0
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

import "../controls"
import "../."

Rectangle {
    id: background
    color:                                                      Style.pageBackgroundColor
    radius:                                                     10
    
    property int settingsBtnWidth:                              180

    /* ------------------------- Connection to AppCore. ------------------------- */
    Connections {
        target: appCore
    }
    /* -------------------------------------------------------------------------- */

    Rectangle {
        id: authSection
        color:                                                  Style.transparent

        anchors.top:                                            parent.top
        anchors.bottom:                                         settingsSave.top
        anchors.left:                                           parent.left
        anchors.right:                                          parent.right
        anchors.margins:                                        0

        Button {
            id: authButton
            flat:                                               true

            width:                                              250
            height:                                             250

            anchors.centerIn:                                   parent

            property color dynamicColorBtn: if(authButton.down) {
                                                authButton.down ? Style.btnColorClicked : Style.btnColorDefault
                                            } else {
                                                authButton.hovered ? Style.btnColorActive : Style.btnColorDefault
                                            }

            Image {
                id: authButtonIcon
                source:                                         "../../images/svg/settings/gdrive-warning.svg"
                antialiasing:                                   false

                width:                                          200
                height:                                         200
                sourceSize.width:                               authButtonIcon.width
                sourceSize.height:                              authButtonIcon.height
                fillMode:                                       Image.PreserveAspectFit

                anchors.centerIn:                               parent
            }

            ColorOverlay {
                anchors.fill:                                   authButtonIcon
                source:                                         authButtonIcon
                color:                                          "#fff"
                antialiasing:                                   true
            }

            background: Rectangle {
                color:                                          authButton.dynamicColorBtn
                radius:                                         authButtonIcon.width

                anchors.fill:                                   parent
            }

            onClicked: {
                appCore.auth();
            }
        }

        Text {
            id: authButtonCaption

            height:                                             30

            text:                                               "Autorization needed first"
            color:                                              "#fff"
            font.family:                                        Style.fontName
            font.pointSize:                                     Style.fontSize + 2
            verticalAlignment:                                  Text.AlignVCenter
            horizontalAlignment:                                Text.AlignHCenter

            anchors.top:                                        authButton.bottom
            anchors.left:                                       parent.left
            anchors.right:                                      parent.right
        }
    }

    Rectangle {
        id: settingsSave
        color:                                                  Style.transparent

        height:                                                 40

        anchors.right:                                          parent.right
        anchors.left:                                           parent.left
        anchors.bottom:                                         parent.bottom
        anchors.rightMargin:                                    0
        anchors.leftMargin:                                     0
        anchors.bottomMargin:                                   20

        ImageSettingsBtn {
            id: importFromGDrive
            width: settingsBtnWidth
            innerText: "Import from GDrive"
            imagePath: "../../images/svg/settings/import.svg"

            anchors.right:                                      parent.right
            anchors.verticalCenter:                             parent.verticalCenter
            anchors.rightMargin:                                ((parent.width / 2) - importFromGDrive.width) / 2

            onClicked:  {
                appCore.importFromGDrive();
            }
        }

        ImageSettingsBtn {
            id: exportToGDrive
            width: settingsBtnWidth
            innerText: "Export to GDrive"
            imagePath: "../../images/svg/settings/export.svg"

            anchors.left:                                       parent.left
            anchors.verticalCenter:                             parent.verticalCenter
            anchors.leftMargin:                                 ((parent.width / 2) - exportToGDrive.width) / 2

            onClicked: {
                appCore.uploadLinkList();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
