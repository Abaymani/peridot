import QtQuick
import qs.common.looks as Looks
import qs

// A small uppercase heading over a group of results.
Looks.ClearText {
  font.pixelSize: Looks.Fonts.size - 2
  font.weight: Font.Bold
  font.letterSpacing: 1
  font.capitalization: Font.AllUppercase
  opacity: 0.55
  leftPadding: 8
  color: Settings.textColorOnContainer
}
