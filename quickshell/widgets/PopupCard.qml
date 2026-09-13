import QtQuick
import qs.common.looks as Looks
import qs

// The shell's popup surface: rounded, with the secondary gradient (or the
// flat container color) over a backdrop floor.
Rectangle {
  radius: Looks.Decorations.decor.radius
  color: Looks.Colors.md3.secondary_container
  gradient: Settings.gradientBgEnabled
    ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject()
    : null

  BackdropFloor {}
}
