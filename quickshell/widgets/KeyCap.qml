import QtQuick
import qs.common.looks as Looks
import qs.common.functions
import qs

// A key, as key hints draw it.
Rectangle {
  property alias text: label.text

  implicitWidth: label.implicitWidth + 10
  implicitHeight: 18
  radius: 5
  color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.12)

  Looks.ClearText {
    id: label
    anchors.centerIn: parent
    font.pixelSize: Looks.Fonts.size - 2
    color: Settings.textColorOnContainer
  }
}
