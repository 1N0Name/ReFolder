import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts 1.15

import "controls"
import "pages"
import "."

Window {
    id: mainWindow
    title: qsTr("ReFolder")
    color:                                                  Style.transparent

    width:                                                  1000
    height:                                                 600
    minimumWidth:                                           1000
    minimumHeight:                                          600
    visible:                                                true

    // Turning off default title bar.
    flags: Qt.Window | Qt.FramelessWindowHint

    // Current windows states.
    property int windowStatus:                              0
    property int windowMargin:                              10

    /* -------------------- Internal properties / functions. -------------------- */
    QtObject {
        id: internal

        function resetResizeBorders() {
            resizeLeft.visible =                            true
            resizeRight.visible =                           true
            resizeBottom.visible =                          true
            windowResize.visible =                          true
        }

        function maximizeRestore() {
            if(windowStatus == 0) {
                windowStatus =                              1
                windowMargin =                              0
                appContainer.radius =                       0
                mainWindow.showMaximized()

                resizeLeft.visible =                        false
                resizeRight.visible =                       false
                resizeBottom.visible =                      false
                windowResize.visible =                      false

                btnMaximize.btnIconSource =                 "../../images/svg/windowControl/maximize_restore.svg"
            } else {
                windowStatus =                              0
                windowMargin =                              10
                appContainer.radius =                       10
                mainWindow.showNormal()
                resetResizeBorders()

                btnMaximize.btnIconSource =                 "../../images/svg/windowControl/maximize_btn.svg"
            }
        }

        // Restore window after draging.
        function ifMaximizedRestore() {
            if (windowStatus == 1) {
                windowStatus =                              0
                windowMargin =                              10
                appContainer.radius =                       10
                resetResizeBorders()

                btnMaximize.btnIconSource =                 "../../images/svg/windowControl/maximize_btn.svg"
            }
        }

        // Restore margins after minimization.
        function restoreMargins() {
            windowStatus =                                  0
            windowMargin =                                  10
            appContainer.radius =                           10
            resetResizeBorders()

            btnMaximize.btnIconSource =                     "../../images/svg/windowControl/maximize_btn.svg"
        }
        
        /* -------------------- Change App theme (light / dark). -------------------- */
//        function setTheme(index) {
//            if (index) {
//                Style.borderWidth =                         0

//                Style.windowBackgroundColor =               "#121212"
//                Style.toolbarBackgroundColor =              "#1f1f1f"
//                Style.toolbarAdditionalColor =              Qt.darker(Style.toolbarBackgroundColor, 1.2)
//                Style.containerBackgroundColor =            "#1d1d1d"

//                Style.highEmphasis =                        "#ffffff"
//                Style.mediumEmphasis =                      "#c1c1c1"
//                Style.disabled =                            "#989898"

//                Style.primaryColor =                        "#9AA9ED"
//                Style.errorColor =                          "#CF6679"
//                Style.iconColor =                           "#ffffff"
//            } else {
//                Style.borderWidth =                         1

//                Style.windowBackgroundColor =               "#f6f8fa"
//                Style.toolbarBackgroundColor =              "#2D53CC"
//                Style.toolbarAdditionalColor =              Qt.lighter(Style.toolbarBackgroundColor, 1.2)
//                Style.containerBackgroundColor =            "#ffffff"

//                Style.highEmphasis =                        "#000000"
//                Style.mediumEmphasis =                      "#000000"
//                Style.disabled =                            "#000000"

//                Style.primaryColor =                        "#2d53cc"
//                Style.errorColor =                          "#B00020"
//                Style.iconColor =                           "#F1F1F1"
//            }
//        }
        /* -------------------------------------------------------------------------- */
    }
    /* -------------------------------------------------------------------------- */

    /* ------------------------- Connection to AppCore. ------------------------- */
    Connections {
        target: appCore

        function onGoToBrowser() {
            if (browserPage.amountOfActiveElements < 1) {
                btnHomePage.isActive = false
                btnSettings.isActive = false
                btnBrowserPage.isActive = true

                stackLayout.currentIndex = 2
            }
        }

        function onGoToHomePage() {
            btnSettings.isActive = false
            btnBrowserPage.isActive = false
            btnHomePage.isActive = true

            stackLayout.currentIndex = 0
        }
    }
    /* -------------------------------------------------------------------------- */

    Rectangle {
        id: background
        color: Style.transparent
        z: 1

        anchors.left:                                       parent.left
        anchors.right:                                      parent.right
        anchors.top:                                        parent.top
        anchors.bottom:                                     parent.bottom
        anchors.leftMargin:                                 windowMargin
        anchors.rightMargin:                                windowMargin
        anchors.bottomMargin:                               windowMargin
        anchors.topMargin:                                  windowMargin
        
        Rectangle {
            id: appContainer
            color: Style.windowBackgroundColor
            radius:                                         10

            anchors.fill:                                   parent
            anchors.leftMargin:                             0
            anchors.rightMargin:                            0
            anchors.bottomMargin:                           0
            anchors.topMargin:                              0

            /* -------------------------------------------------------------------------- */
            /*                                  Top Bar.                                  */
            /* -------------------------------------------------------------------------- */
            Rectangle {
                id: topBar
                height: 50
                color: Style.transparent

                anchors.left:                               parent.left
                anchors.right:                              parent.right
                anchors.top:                                parent.top
                anchors.leftMargin:                         0
                anchors.rightMargin:                        0
                anchors.topMargin:                          0

                /* ---------------------------- Application Logo. --------------------------- */
                Rectangle {
                    id: appLogo
                    color:                                  Style.transparent

                    width: 50
                    height: 50
                    radius: 10

                    Image {
                        id: appLogoImage

                        source:                             "../images/svg/app_logo.svg"
                        fillMode:                           Image.PreserveAspectFit
                        mipmap:                             true

                        anchors.fill:                       parent
                        anchors.verticalCenter:             parent.verticalCenter
                        anchors.horizontalCenter:           parent.horizontalCenter
                    }

                    ColorOverlay {
                        anchors.fill:                       appLogoImage
                        source:                             appLogoImage
                        color:                              Style.iconColor
                        antialiasing:                       true
                    }

                    anchors.left: parent.left
                    anchors.top: parent.rop
                }
                /* -------------------------------------------------------------------------- */
                
                /* ------------------------------- Title Bar. ------------------------------- */
                Rectangle {
                    id: titleBar
                    color: Style.transparent

                    height:                                 parent.height

                    anchors.left:                           parent.left
                    anchors.right:                          parent.right
                    anchors.top:                            parent.top
                    anchors.leftMargin:                     50
                    anchors.rightMargin:                    105
                    anchors.topMargin:                      0

                    // Adding ability to drag window.
                    DragHandler {
                        onActiveChanged: if(active) {
                                             mainWindow.startSystemMove()
                                             internal.ifMaximizedRestore()
                                         }
                    }
                    
                    // App title.
                    Label {
                        id: appTitle
                        color: "#ffffff"
                        text: qsTr("ReFolder")

                        font.family:                        Style.fontName
                        font.pointSize:                     Style.fontSize
                        font.bold:                          true
                        horizontalAlignment:                Text.AlignLeft
                        verticalAlignment:                  Text.AlignVCenter

                        anchors.left:                       parent.left
                        anchors.right:                      parent.right
                        anchors.top:                        parent.top
                        anchors.bottom:                     parent.bottom
                        anchors.leftMargin:                 5
                    }
                }
                /* -------------------------------------------------------------------------- */

                /* -------------------------- Windows control btns. ------------------------- */
                Row {
                    id: rowBtns
                    width: 105
                    height: 35

                    anchors.right:                          parent.right
                    anchors.top:                            parent.top
                    anchors.topMargin:                      0
                    anchors.rightMargin:                    0

                    TopBarBtn {
                        id: btnMinimize
                        btnIconSource:                      "../../images/svg/windowControl/minimize_btn.svg"

                        onClicked: {
                            mainWindow.showMinimized()
                            internal.restoreMargins()
                        }
                    }

                    TopBarBtn {
                        id: btnMaximize
                        btnIconSource:                      "../../images/svg/windowControl/maximize_btn.svg"

                        onClicked: internal.maximizeRestore()
                    }

                    TopBarBtn {
                        id: btnClose
                        btnIconSource:                      "../../images/svg/windowControl/close_btn.svg"

                        btnColorMouseOver:                  Style.errorColor
                        btnColorClicked:                    Qt.darker(Style.errorColor, 1.2)
                        onClicked: mainWindow.close()
                    }
                }
            }
            /* -------------------------------------------------------------------------- */

            /* -------------------------------------------------------------------------- */
            /*                                Main Content.                               */
            /* -------------------------------------------------------------------------- */
            Rectangle {
                id: content
                color: Style.transparent

                anchors.left:                               parent.left
                anchors.right:                              parent.right
                anchors.top:                                topBar.bottom
                anchors.bottom:                             parent.bottom
                anchors.topMargin:                          0

                /* ------------------------------- Side Menu. ------------------------------- */
                Rectangle {
                    id: sideMenu
                    width: 50
                    color: Style.transparent
                    clip: true

                    anchors.left:                           parent.left
                    anchors.top:                            parent.top
                    anchors.bottom:                         parent.bottom
                    anchors.leftMargin:                     0
                    anchors.bottomMargin:                   0
                    anchors.topMargin:                      0

                    // Side menu animation.
                    PropertyAnimation {
                        id: animationSideMenu
                        target: sideMenu
                        property: "width"
                        to: (sideMenu.width == 50) ? 180 : 50
                        duration: 1000
                        easing.type: Easing.InOutCubic
                    }

                    Column {
                        id: column

                        anchors.fill:                       parent
                        anchors.leftMargin:                 0
                        anchors.rightMargin:                0
                        anchors.topMargin:                  0
                        anchors.bottomMargin:               90

                        SideMenuBtn {
                            id: btnToggle

                            btnIconSource:                  "../../images/svg/sideMenu/menu_btn.svg"

                            onClicked: {
                                animationSideMenu.running = true
                            }
                        }

                        Item {
                            width:                          1
                            height:                         5
                        }

                        SideMenuBtn {
                            id: btnHomePage
                            text: qsTr("Home Page")
                            anchors.right:                  parent.right
                            anchors.rightMargin:            5

                            btnIconSource:                  "../../images/svg/sideMenu/home_page.svg"
                            isActive:                       true

                            onClicked: {
                                btnSettings.isActive = false
                                btnBrowserPage.isActive = false
                                btnHomePage.isActive = true

                                stackLayout.currentIndex = 0
                            }
                        }

                        Item {
                            width:                          1
                            height:                         5
                        }

                        SideMenuBtn {
                            id: btnBrowserPage
                            text: qsTr("Browser")
                            enabled:                        browserPage.amountOfActiveElements > 0? true : false

                            anchors.right:                  parent.right
                            anchors.rightMargin:            5

                            btnIconSource:                  "../../images/svg/sideMenu/ebook_page.svg"
                            isActive:                       false

                            onClicked: {
                                btnHomePage.isActive = false
                                btnSettings.isActive = false
                                btnBrowserPage.isActive = true

                                stackLayout.currentIndex = 2
                            }
                        }
                    }

                    SideMenuBtn {
                        id: btnSettings
                        text:                               qsTr("Settings")
                        anchors.right:                      parent.right
                        anchors.rightMargin:                5

                        btnIconSource:                      "../../images/svg/sideMenu/settings_page.svg"
                        isActive:                           false

                        anchors.left:                       parent.left
                        anchors.bottom:                     parent.bottom
                        anchors.margins:                    5
                        anchors.bottomMargin:               25

                        onClicked: {
                            btnHomePage.isActive = false
                            btnBrowserPage.isActive = false
                            isActive = true

                            stackLayout.currentIndex = 1
                        }
                    }

                    // App version.
                    Label {
                        id: version
                        color:                              Style.mediumEmphasis
                        text:                               qsTr("v 1.0.0")

                        width:                              sideMenu.width

                        font.family:                        Style.fontName
                        font.pointSize:                     8
                        font.bold:                          true
                        horizontalAlignment:                Text.AlignHCenter
                        verticalAlignment:                  Text.AlignVCenter

                        anchors.left:                       parent.left
                        anchors.right:                      parent.right
                        anchors.top:                        btnSettings.bottom
                        anchors.bottom:                     parent.bottom
                    }
                }
                /* -------------------------------------------------------------------------- */

                /* --------------------------------- Pages. --------------------------------- */
                Rectangle {
                    id: contentPages
                    color: Style.transparent
                    clip: true

                    anchors.left:                           sideMenu.right
                    anchors.right:                          parent.right
                    anchors.top:                            parent.top
                    anchors.bottom:                         parent.bottom
                    anchors.bottomMargin:                   25
                    anchors.rightMargin:                    0
                    anchors.leftMargin:                     0
                    anchors.topMargin:                      0

                    StackLayout {
                        id: stackLayout
                        anchors.fill: parent
                        currentIndex: 0

                        HomePage {
                            id: homePage
                        }

                        SettingsPage {
                            id: settingsPage
                        }

                        BrowserPage {
                            id: browserPage
                        }
                    }
                }
                /* -------------------------------------------------------------------------- */

                /* ------------------------------- Bottom bar. ------------------------------ */
                Rectangle {
                    id: bottomBar
                    color: Style.transparent

                    anchors.left:                           sideMenu.right
                    anchors.right:                          parent.right
                    anchors.top:                            contentPages.bottom
                    anchors.bottom:                         parent.bottom
                    anchors.rightMargin:                    0
                    anchors.leftMargin:                     0
                    anchors.bottomMargin:                   0
                    anchors.topMargin:                      0

                    // Copyright.
                    Label {
                        id: bottomBarLabel
                        color: "#ffffff"
                        text: qsTr("© Copyright 2021 ReFolder.")

                        font.family:                        Style.fontName
                        font.pointSize:                     8
                        font.italic:                        false
                        horizontalAlignment:                Text.AlignLeft
                        verticalAlignment:                  Text.AlignVCenter

                        anchors.left:                       parent.left
                        anchors.right:                      parent.right
                        anchors.top:                        parent.top
                        anchors.bottom:                     parent.bottom
                        anchors.rightMargin:                30
                        anchors.leftMargin:                 10
                        anchors.bottomMargin:               0
                        anchors.topMargin:                  0
                    }

                    MouseArea {
                        id: windowResize

                        width:                              25
                        height:                             25

                        anchors.right:                      parent.right
                        anchors.bottom:                     parent.bottom
                        anchors.bottomMargin:               0
                        anchors.rightMargin:                0

                        cursorShape:                        Qt.SizeFDiagCursor

                        Image {
                            id: image

                            source:                         "../images/svg/windowControl/resize_btn.svg"
                            fillMode:                       Image.PreserveAspectFit
                            opacity:                        0.5
                            antialiasing:                   false


                            anchors.fill:                   parent
                            anchors.leftMargin:             5
                            anchors.topMargin:              5
                            sourceSize.height:              16
                            sourceSize.width:               16
                        }

                        ColorOverlay {
                            anchors.fill:                   image
                            source:                         image
                            color:                          (Style.windowBackgroundColor == "#121212") ? "#999999" : "#ffffff"
                            antialiasing:                   false
                        }

                        onPressed: {
                            mainWindow.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
                        }

                    }
                }
                /* -------------------------------------------------------------------------- */
            }
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                            Window resize areas.                            */
    /* -------------------------------------------------------------------------- */
    
    // Left.
    MouseArea {
        id: resizeLeft
        width:                                              10

        anchors.left:                                       parent.left
        anchors.top:                                        parent.top
        anchors.bottom:                                     parent.bottom
        anchors.leftMargin:                                 0
        anchors.bottomMargin:                               10
        anchors.topMargin:                                  10

        cursorShape:                                        Qt.SizeHorCursor

        onPressed: {
            mainWindow.startSystemResize(Qt.LeftEdge)
        }
    }

    // Right.
    MouseArea {
        id: resizeRight
        width:                                              10

        anchors.right:                                      parent.right
        anchors.top:                                        parent.top
        anchors.bottom:                                     parent.bottom
        anchors.rightMargin:                                0
        anchors.bottomMargin:                               10
        anchors.topMargin:                                  10

        cursorShape:                                        Qt.SizeHorCursor

        onPressed: {
            mainWindow.startSystemResize(Qt.RightEdge)
        }
    }

    // Bottom.
    MouseArea {
        id: resizeBottom
        height:                                             10

        anchors.left:                                       parent.left
        anchors.right:                                      parent.right
        anchors.bottom:                                     parent.bottom
        anchors.rightMargin:                                10
        anchors.leftMargin:                                 10
        anchors.bottomMargin:                               0

        cursorShape:                                        Qt.SizeVerCursor

        onPressed: {
            mainWindow.startSystemResize(Qt.BottomEdge)
        }
    }


    // Top.
    MouseArea {
        id: resizeTop
        height:                                             10

        anchors.left:                                       parent.left
        anchors.right:                                      parent.right
        anchors.top:                                        parent.top
        anchors.topMargin:                                  0
        anchors.leftMargin:                                 10
        anchors.rightMargin:                                10

        cursorShape:                                        Qt.SizeVerCursor

        onPressed: {
            mainWindow.startSystemResize(Qt.TopEdge)
        }
    }
    /* -------------------------------------------------------------------------- */
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.8999999761581421}
}
##^##*/
