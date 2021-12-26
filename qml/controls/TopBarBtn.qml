import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

import "../."

Button {
    id: btnTopBar

    flat: true

    property url btnIconSource:                                             "../../images/svg/minmize.svg"

    property alias btnWidth:                                                btnTopBar.width
    property alias btnHeight:                                               btnTopBar.height
    property color btnColorDefault:                                         Style.btnColorDefault
    property color btnColorMouseOver:                                       Style.btnColorActive
    property color btnColorClicked:                                         Style.btnColorClicked

    QtObject {
        id: internal

        property var dynamicColor: if(btnTopBar.down) {
                                       btnTopBar.down ? btnColorClicked : btnColorDefault
                                   } else {
                                       btnTopBar.hovered ? btnColorMouseOver : btnColorDefault
                                   }
    }


    width: 35
    height: 35

    background: Rectangle {
        id: bgBtn
        color:                                                              internal.dynamicColor

        Image {
            id: iconBtn
            source:                                                         btnIconSource
            width:                                                          16
            height:                                                         16

            anchors.verticalCenter:                                         parent.verticalCenter
            anchors.horizontalCenter:                                       parent.horizontalCenter
            fillMode:                                                       Image.PreserveAspectFit
            visible:                                                        false
        }

        ColorOverlay {
            anchors.fill:                                                   iconBtn
            source:                                                         iconBtn
            color:                                                          "#ffffff"
            antialiasing:                                                   true
        }
    }
}
