import QtQuick
import qs.common.looks as Looks
import qs

// Shared background/shape for the small pill-shaped containers used throughout
// the bar and control center (icon+text groups, status indicators, etc).
// Consumers are still responsible for sizing themselves (implicitWidth) and
// laying out their own content - Pill only owns the repeated styling.
Rectangle {
  id: root

  property string gradientKey: Settings.activeGradient

  implicitHeight: Looks.Decorations.decor.elementHeight
  radius: Looks.Decorations.decor.radius
  color: Looks.Colors.md3.secondary_container
  gradient: Settings.gradientBgEnabled
    ? Looks.Gradients.library[gradientKey].createObject()
    : null
}
