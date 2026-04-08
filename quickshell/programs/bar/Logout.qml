import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.common.looks as Looks

RowLayout {
  id: root

  Text {
    text: ""
    color: Looks.Colors.palette.neutral100
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size + 4
    
    MouseArea{
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: (mouse) => {
        if (mouse.button === Qt.LeftButton) {Quickshell.execDetached(["wlogout"])}
        else if (mouse.button === Qt.RightButton) {Quickshell.execDetached(["hyprlock"])}
      }
    }
  }
}