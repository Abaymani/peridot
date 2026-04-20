import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs

RowLayout {
  id: root

  Text {
    text: " "
    color: Settings.textColorNotContainer
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size + 4

    renderTypeQuality: 16 // Helps with legibility on light wallpapers
    style: Text.Outline
    styleColor: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral0, 0.1)
    
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