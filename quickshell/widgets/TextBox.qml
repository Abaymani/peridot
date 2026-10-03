import QtQuick
import QtQuick.Controls
import qs.common.looks as Looks
import qs.common.functions
import qs

// A one-line text input for settings rows.
TextField {
  id: root

  implicitHeight: Looks.Decorations.decor.elementHeight
  leftPadding: 10
  rightPadding: 10
  verticalAlignment: TextInput.AlignVCenter
  color: Settings.textColorOnContainer
  placeholderTextColor: Looks.Colors.palette.neutral70
  selectionColor: Looks.Colors.md3.primary
  selectedTextColor: Looks.Colors.md3.on_primary
  font.family: Looks.Fonts.family
  font.pixelSize: Looks.Fonts.size

  background: Rectangle {
    radius: Looks.Decorations.decor.radius
    color: Settings.gradientBgEnabled
      ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
      : Looks.Colors.md3.secondary_container
    border.width: 1
    border.color: root.activeFocus ? Looks.Colors.md3.primary : "#00000000"
  }
}
