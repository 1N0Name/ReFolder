import QtQuick 2.5
import QtQuick.Controls 2.15

import "../."

Button {
    id: button
    flat: true

    // Global Properties.
    property string imagePath: "../../images/svg/import.svg"
    property string innerText: "hello"

    width: buttonImage.width + rectangleDivider.width + tMetrics.width + 40
    height: 35
    implicitWidth: 130
    implicitHeight: 35

    QtObject {
        id: internal

        property var dynamicColor: if(button.down) {
                                       button.down ? Style.primaryClickedColor : Style.primaryColor
                                   } else {
                                       button.hovered ? Style.primaryHoveredColor : Style.primaryColor
                                   }
    }

    Image {
        id: buttonImage
        source: imagePath
        antialiasing: true

        width:                  20
        height:                 20
        sourceSize.width:       20
        sourceSize.height:      20
        fillMode:               Image.PreserveAspectFit

        anchors.left:           parent.left
        anchors.leftMargin:     10
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: rectangleDivider
        width: 1
        height: parent.height
        color: "#000"

        anchors.left:           buttonImage.right
        anchors.bottom:         parent.bottom
        anchors.top:            parent.top
        anchors.leftMargin:     10
        anchors.bottomMargin:   0
        anchors.topMargin:      0
    }

    contentItem: Text {
        id: contentText

        text:                   innerText
        color:                  (Style.windowBackgroundColor == "#121212") ? "#000000" : "#ffffff"
        font.family:            Style.fontName
        font.pointSize:         Style.fontSize
        verticalAlignment:      Text.AlignVCenter
        horizontalAlignment:    Text.AlignHCenter

        anchors.left:           rectangleDivider.right
        anchors.right:          parent.right
        anchors.leftMargin:     10
        anchors.rightMargin:    10
    }

    TextMetrics {
        id: tMetrics
        font: contentText.font
        text: contentText.text
    }

    background: Rectangle {
        radius: 3
        color: internal.dynamicColor
    }

    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse.accepted = false
    }
}
