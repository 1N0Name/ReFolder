import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

import "."
import "../."

Dialog {
    id: inputDialog

    // Global properties.
    property alias headerText:                                      headerText.text

    property alias firstFieldText:                                  headerField.text
    property string phFirstText:                                    "Enter entry name..."
    property alias secondFieldText:                                 linkField.text
    property string phSecondText:                                   "Enter link to webpage..."
    property bool hasSecondInputField:                              false

    property alias firstBtnName:                                    firstBtnText.text
    property alias secondBtnName:                                   secondBtnText.text

    property int containerWidth:                                    240
    property int containerHeight:                                   145

    width:                                                          containerWidth
    height:                                                         hasSecondInputField? containerHeight :
                                                                                         containerHeight - 35

    clip: false

    header: Rectangle {
        id: headerBackgound
        color:                                                      Style.transparent

        width:                                                      parent.width
        height:                                                     30

        Text {
            id: headerText

            text:                                                   qsTr('')
            color:                                                  "#fff"
            font.family:                                            Style.fontName
            font.pointSize:                                         Style.fontSize + 2
            font.bold:                                              true
            verticalAlignment:                                      Text.AlignVCenter

            leftPadding:                                            parent.width / 2 - tHeaderText.width / 2
            anchors.top:                                            parent.top
            anchors.bottom:                                         parent.bottom
            anchors.margins:                                        0
        }

        TextMetrics {
            id: tHeaderText
            font:                                                   headerText.font
            text:                                                   headerText.text
        }

        TopBarBtn {
            id: btnClose
            btnIconSource:                                          "../../images/svg/windowControl/close_btn.svg"

            btnColorMouseOver:                                      Style.errorColor
            btnColorClicked:                                        Qt.darker(Style.errorColor, 1.2)

            btnWidth:                                               parent.height
            btnHeight:                                              parent.height

            anchors.right:                                          parent.right
            anchors.margins:                                        0

            onClicked: {
                close()
            }
        }
    }

    contentItem: Column {
        id: content

        anchors.left:                                               parent.left
        anchors.right:                                              parent.right
        anchors.top:                                                headerBackgound.bottom
        anchors.bottom:                                             footerBackground.top
        anchors.margins: 5

        TextField {
            id: headerField

            width:                                                  parent.width
            height:                                                 30

            Text {
                text:                                               phFirstText
                visible:                                            !headerField.text && !headerField.activeFocus

                color:                                              Style.disabled
                font.family:                                        Style.fontName
                font.pointSize:                                     Style.fontSize

                anchors.fill:                                       parent
                anchors.leftMargin:                                 5
                verticalAlignment:                                  Text.AlignVCenter
            }

            color:                                                  "#fff"
            font.family:                                            Style.fontName
            font.pointSize:                                         Style.fontSize
            verticalAlignment:                                      Text.AlignVCenter
            selectByMouse:                                          true

            onActiveFocusChanged: {
                if (headerField.activeFocus) {
                    headerFieldBg.border.color =                    Style.primaryColor
                } else {
                    headerFieldBg.border.color =                    Style.disabled
                }
            }

            background: Rectangle {
                id: headerFieldBg
                color:                                              Style.transparent
                radius:                                             5
                border.width:                                       1
                border.color:                                       Style.disabled
            }
        }

        Item {
            width:                                                  1
            height:                                                 5
        }

        TextField {
            id: linkField
            visible: hasSecondInputField

            width:                                                  parent.width
            height:                                                 30

            Text {
                text:                                               phSecondText
                visible:                                            !linkField.text && !linkField.activeFocus

                color:                                              Style.disabled
                font.family:                                        Style.fontName
                font.pointSize:                                     Style.fontSize

                anchors.fill:                                       parent
                anchors.leftMargin:                                 5
                verticalAlignment:                                  Text.AlignVCenter
            }

            color:                                                  "#fff"
            font.family:                                            Style.fontName
            font.pointSize:                                         Style.fontSize
            verticalAlignment:                                      Text.AlignVCenter
            selectByMouse:                                          true

            onActiveFocusChanged: {
                if (linkField.activeFocus) {
                    linkFieldBg.border.color =                      Style.primaryColor
                } else {
                    linkFieldBg.border.color =                      Style.disabled
                }
            }

            background: Rectangle {
                id: linkFieldBg
                color:                                              Style.transparent
                radius:                                             5
                border.width:                                       1
                border.color:                                       Style.disabled
            }
        }
    }

    footer: Rectangle {
        id: footerBackground
        color:                                                      Style.transparent

        width:                                                      parent.width
        height:                                                     40

        Button {
            id: firstBtn
            flat: true

            property var dynamicColor: if(firstBtn.down) {
                                           firstBtn.down ? Style.primaryClickedColor : Style.primaryColor
                                       } else {
                                           firstBtn.hovered ? Style.primaryHoveredColor: Style.primaryColor
                                       }

            height:                                                 30
            width:                                                  tFirstBtnText.width + 20

            anchors.left:                                           parent.left
            anchors.verticalCenter:                                 parent.verticalCenter
            anchors.leftMargin:                                     hasSecondInputField? ((parent.width / 2) - firstBtn.width) / 2 :
                                                                                         (parent.width - firstBtn.width) / 2

            contentItem: Text {
                id: firstBtnText

                text:                                               qsTr("Create Folder")
                color:                                              "#fff"
                font.family:                                        Style.fontName
                font.pointSize:                                     Style.fontSize
                verticalAlignment:                                  Text.AlignVCenter
                horizontalAlignment:                                Text.AlignHCenter

                anchors.fill:                                       parent
            }

            TextMetrics {
                id: tFirstBtnText
                font:                                               firstBtnText.font
                text:                                               firstBtnText.text
            }

            background: Rectangle {
                color:                                              firstBtn.dynamicColor
                radius:                                             10
            }

            onClicked:  {
                applied()
                // Clear Input Fields.
                headerField.text = ""
                linkField.text = ""
                close()
            }
        }

        Button {
            id: secondBtn
            visible: hasSecondInputField
            flat: true

            property var dynamicColor: if(secondBtn.down) {
                                           secondBtn.down ? Style.primaryClickedColor : Style.primaryColor
                                       } else {
                                           secondBtn.hovered ? Style.primaryHoveredColor: Style.primaryColor
                                       }

            height:                                                 30
            width:                                                  tSecondBtnText.width + 20

            anchors.right:                                          parent.right
            anchors.verticalCenter:                                 parent.verticalCenter
            anchors.rightMargin:                                    ((parent.width / 2) - secondBtn.width) / 2

            contentItem: Text {
                id: secondBtnText

                text:                                               qsTr("Create Link")
                color:                                              "#fff"
                font.family:                                        Style.fontName
                font.pointSize:                                     Style.fontSize
                verticalAlignment:                                  Text.AlignVCenter
                horizontalAlignment:                                Text.AlignHCenter

                anchors.fill:                                       parent
            }

            TextMetrics {
                id: tSecondBtnText
                font:                                               secondBtnText.font
                text:                                               secondBtnText.text
            }

            background: Rectangle {
                color:                                              secondBtn.dynamicColor
                radius:                                             10
            }

            onClicked: {
                accepted()
                // Clear Input Fields.
                headerField.text = ""
                linkField.text = ""
                close()
            }
        }
    }

    background: Rectangle {
        id: background
        color:                                                      Style.delegateColor
        radius:                                                     10
    }

    standardButtons: firstBtn | secondBtn
}
