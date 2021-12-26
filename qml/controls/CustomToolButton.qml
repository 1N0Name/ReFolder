import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

import "../."

ToolButton {
    id: toolButton

    // Global Properties.
    property alias btnIconSource:                           toolButtonImage.source

    // Local Properties.
    property color dynamicColorBtn: if(toolButton.down) {
                                        toolButton.down ? Style.btnColorClicked : Style.btnColorDefault
                                    } else {
                                        toolButton.hovered ? Style.btnColorActive : Style.btnColorDefault
                                    }

    implicitWidth:                                          parent.height - 5
    implicitHeight:                                         parent.height - 5

    Image {
        id: toolButtonImage
        source:                                             "../../images/svg/controlMenu/raw.svg"
        antialiasing:                                       false

        width:                                              toolButton.width - 10
        height:                                             toolButton.height - 10
        sourceSize.width:                                   toolButton.width - 10
        sourceSize.height:                                  toolButton.height - 10
        fillMode:                                           Image.PreserveAspectFit

        anchors.centerIn:                                   parent
    }

    ColorOverlay {
        anchors.fill:                                       toolButtonImage
        source:                                             toolButtonImage
        color:                                              "#fff"
        antialiasing:                                       true
    }

    background: Rectangle {
        color:                                              dynamicColorBtn
        radius:                                             5

        anchors.fill:                                       parent
    }
}
