import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

import "../."

Button {
    id: fileMenuButton
    flat: true

    // Global Properties.
    property alias buttonWidth:                             fileMenuIcon.width
    property alias buttonHeight:                            fileMenuIcon.height

    property alias iconWidth:                               fileMenuIcon.implicitWidth
    property alias iconHeight:                              fileMenuIcon.implicitHeight
    property alias btnIconSource:                           fileMenuIcon.source


    // Local Properties.
    property color dynamicColorBtn: if(fileMenuButton.down) {
                                        fileMenuButton.down ? Style.btnColorClicked : Style.btnColorDefault
                                    } else {
                                        fileMenuButton.hovered ? Style.btnColorActive : Style.btnColorDefault
                                    }

    implicitWidth: 30
    implicitHeight: 30

    Image {
        id: fileMenuIcon
        source:                                             "../../images/svg/fileSystem/left-arrow.svg"
        antialiasing:                                       false

        width:                                              20
        height:                                             20
        sourceSize.width:                                   fileMenuIcon.width
        sourceSize.height:                                  fileMenuIcon.height
        fillMode:                                           Image.PreserveAspectFit

        anchors.left:                                       parent.left
        anchors.leftMargin:                                 (fileMenuButton.width - fileMenuIcon.width) / 2
        anchors.verticalCenter:                             parent.verticalCenter
    }

    ColorOverlay {
        anchors.fill:                                       fileMenuIcon
        source:                                             fileMenuIcon
        color:                                              "#fff"
        antialiasing:                                       true
    }

    background: Rectangle {
        color:                                              dynamicColorBtn
        radius:                                             5
    }
}
