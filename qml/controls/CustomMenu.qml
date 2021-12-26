import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

import "../."

Menu {
    id: contextMenu

    // Global Properties.
    property alias menuWidth :                                  contextMenuBg.implicitWidth
    property bool hasIcon:                                      true
    property bool hasRadioButton:                               false
    property int currentActive:                                 -1

    padding:                                                    5

    delegate: MenuItem {
        id: menuItem
        implicitWidth:                                          contextMenuBg.implicitWidth
        implicitHeight:                                         30
        spacing:                                                5

        property color dynamicColorMenu: if(menuItem.down) {
                                             menuItem.down ? Style.btnColorClicked : Style.transparent
                                         } else {
                                             menuItem.hovered ? Style.btnColorActive : Style.transparent
                                         }

        Image {
            id: menuItemIcon
            visible:                                            hasIcon
            source:                                             menuItem.icon.source
            antialiasing:                                       false

            width:                                              20
            height:                                             20
            sourceSize.width:                                   20
            sourceSize.height:                                  20
            fillMode:                                           Image.PreserveAspectFit

            anchors.left:                                       parent.left
            anchors.verticalCenter:                             parent.verticalCenter
            anchors.leftMargin:                                 10
        }

        RadioButton {
            id: menuItemRadioButton
            enabled:                                            false
            hoverEnabled:                                       false
            checked:                                            menuItem.checked
            visible:                                            hasRadioButton

            width:                                              15
            height:                                             15

            indicator: Rectangle {
                id: radioButtonIndicator

                implicitWidth:                                  menuItemRadioButton.width
                implicitHeight:                                 menuItemRadioButton.height
                radius:                                         12

                Rectangle {
                    visible:                                    menuItemRadioButton.checked
                    color:                                      "#555"
                    radius:                                     radioButtonIndicator.radius

                    anchors.fill:                               parent
                    anchors.margins:                            3
                }
            }

            anchors.left:                                       parent.left
            anchors.leftMargin:                                 10
            anchors.verticalCenter:                             parent.verticalCenter
        }

        ColorOverlay {
            visible:                                            hasIcon
            anchors.fill:                                       menuItemIcon
            source:                                             menuItemIcon
            color:                                              "#fff"
            antialiasing:                                       true
        }

        contentItem: Text {
            text:                                               menuItem.text
            color:                                              "#fff"
            font.family:                                        Style.fontName
            font.pointSize:                                     Style.fontSize
            horizontalAlignment:                                Text.AlignLeft
            verticalAlignment:                                  Text.AlignVCenter

            anchors.left:                                       hasIcon? menuItemIcon.right :
                                                                         hasRadioButton? menuItemRadioButton.right : parent.left
            anchors.leftMargin:                                 10
        }

        background: Rectangle {
            id: menuItemBg
            radius:                                             5

            anchors.fill:                                       parent

            color:                                              dynamicColorMenu
        }

        onClicked: {
            if (hasRadioButton && currentActive != currentIndex) {
                contextMenu.actionAt(currentActive).checked = false
                currentActive = currentIndex
                menuItem.checked = true
            }
        }
    }

    Component.onCompleted: {
        if (hasRadioButton && currentActive > -1)
            contextMenu.actionAt(currentActive).checked = true
    }

    background: Rectangle {
        id: contextMenuBg
        implicitWidth:                                          150
        implicitHeight:                                         30
        radius:                                                 5

        color:                                                  Style.delegateColor
    }
}
