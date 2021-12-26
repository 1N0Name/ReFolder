import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

import "../."

TabButton {
    id: tabButton
    text: qsTr('Err')

    // Global properties.
    property alias title:                                   tabButton.text

    // Local Properties.
    property color dynamicColorBtn: if(closeBtn.down) {
                                        closeBtn.down ? Style.btnColorClicked : Style.btnColorDefault
                                    } else {
                                        closeBtn.hovered ? Style.btnColorActive : Style.btnColorDefault
                                    }
    anchors.bottom:                                         parent.bottom
    anchors.bottomMargin:                                   0

    width:                                                  (tabBar.width / tabBar.count) < 160? (tabBar.width / tabBar.count) : 160

    contentItem: Label {
        clip:                                               true

        text:                                               parent.text
        color:                                              "#fff"
        font.family:                                        Style.fontName
        font.pointSize:                                     Style.fontSize - 1
        verticalAlignment:                                  Text.AlignVCenter

        anchors.left:                                       parent.left
        anchors.right:                                      parent.right
        anchors.leftMargin:                                 5
        anchors.rightMargin:                                closeBtn.visible? 30 : 5
    }

    Rectangle {
        width:                                              1
        height:                                             parent.height - 10
        color:                                              Style.disabled

        anchors.left:                                       parent.right
        anchors.verticalCenter:                             parent.verticalCenter
    }

    Button {
        id: closeBtn
        visible:                                            (parent.width > 100)? true : (tabBar.currentIndex == tabButton.TabBar.index)?
                                                                                      true : false
        flat: true

        width:                                              25
        height:                                             25

        anchors.right:                                      parent.right
        anchors.rightMargin:                                5
        anchors.verticalCenter:                             parent.verticalCenter

        Image {
            id: closeBtnImage
            source:                                         "../../images/svg/browser/close.svg"
            antialiasing:                                   false

            width:                                          parent.width - 5
            height:                                         parent.height - 5
            sourceSize.width:                               parent.width - 5
            sourceSize.height:                              parent.height - 5
            fillMode:                                       Image.PreserveAspectFit

            anchors.centerIn:                               parent
        }

        ColorOverlay {
            anchors.fill:                                   closeBtnImage
            source:                                         closeBtnImage
            color:                                          "#fff"
            antialiasing:                                   true
        }

        background: Rectangle {
            color:                                          dynamicColorBtn
            radius:                                         25
        }

        onClicked: {
            if (tabBar.count == 1)
                appCore.goToHomePage()

            stack.children[tabButton.TabBar.index].destroy()
            tabBar.removeItem(tabBar.itemAt(tabButton.TabBar.index))
        }
    }

    background: Rectangle {
        color:                                              (tabBar.currentIndex == tabButton.TabBar.index)? Style.containerBackgroundColor :
                                                                                                          Style.pageBackgroundColor

        anchors.fill:                                       parent
    }
}
