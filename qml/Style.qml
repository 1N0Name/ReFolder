pragma Singleton
import QtQuick 2.0

QtObject {
    property color transparent:                     "#00000000"
    property int borderWidth:                       0

    /* ---------------------------- Text properties. ---------------------------- */
    property string fontName:                       "Arial"
    property int fontSize:                          10
    property color highEmphasis:                    "#ffffff"
    property color mediumEmphasis:                  "#c1c1c1"
    property color disabled:                        "#989898"
    /* -------------------------------------------------------------------------- */

    /* ------------------------ Default color properties. ----------------------- */
    property color windowBackgroundColor:           "#202020"
    property color pageBackgroundColor:             "#272727"
    property color containerBackgroundColor:        "#323232"
    property color delegateColor:                   "#373737"
    property color iconColor:                       "#ffffff"
    /* -------------------------------------------------------------------------- */

    /* -------------------------- Btn Color properties. ------------------------- */
    property color btnColorDefault:                 "#00000000"
    property color btnColorActive:                  "#2d2d2d"
    property color btnColorClicked:                 "#292929"

    property color primaryColor:                    "#9aa9ed"
    property color primaryHoveredColor:             Qt.lighter(primaryColor, 1.2)
    property color primaryClickedColor:             Qt.darker(primaryColor, 1.2)
    property color secondaryColor:                  "#000000"
    property color errorColor:                      "#CF6679"
    /* -------------------------------------------------------------------------- */
}
