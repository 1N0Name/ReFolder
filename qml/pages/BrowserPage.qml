import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

import "../controls"
import "../."


Rectangle {
    id: background
    color:                                                          Style.pageBackgroundColor

    property alias amountOfActiveElements:                          tabBar.count

    layer.enabled:                                                  true
    layer.effect: OpacityMask {
        maskSource: Item {
            width:                                                  background.width
            height:                                                 background.height

            Rectangle {
                width:                                              background.width
                height:                                             background.height
                radius:                                             10
            }
        }
    }

    Connections{

        target: appCore

        function onAddPage(url, name) {
            var newObjectbtn = Qt.createQmlObject('
            import "../controls"

            CustomTabButton {
                text: qsTr("' + name + '")
            }', tabBar);

            stack.children.push(Qt.createQmlObject('
            import "../controls"

            BrowserUnit {
                qurl: \"' + url + '\"
                saveName: "' + name + '.html"
            }', stack));
        }
    }

    TabBar {
        id: tabBar

        height: 30

        contentWidth:                                               parent.width
        contentHeight:                                              25
        spacing:                                                    1
    }

    StackLayout {
        id: stack
        currentIndex:                                               tabBar.currentIndex

        anchors.top:                                                tabBar.bottom
        anchors.bottom:                                             parent.bottom
        anchors.right:                                              parent.right
        anchors.left:                                               parent.left
        anchors.margins:                                            0
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:1}D{i:2}D{i:4}D{i:5}D{i:3}D{i:7}D{i:8}
D{i:9}D{i:6}D{i:12}D{i:13}D{i:11}D{i:20}
}
##^##*/
