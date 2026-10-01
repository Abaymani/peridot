import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs

RowLayout {
  id: root

  Looks.ClearText {
    text: " "
    color: Settings.textColorNotContainer
    font.pixelSize: Looks.Fonts.size + 4

    renderTypeQuality: 16 // Helps with legibility on light wallpapers
    style: Text.Outline
    styleColor: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral0, 0.1)
    
    MouseArea{
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: (mouse) => {
        if (mouse.button === Qt.LeftButton) GlobalStates.isPowerMenuOpen = !GlobalStates.isPowerMenuOpen
        else if (mouse.button === Qt.RightButton) Session.lock()
      }
    }
  }
}