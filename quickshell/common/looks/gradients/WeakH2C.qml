import QtQuick
import qs.common.looks
import qs.common.functions

Gradient {
  orientation: Gradient.Horizontal
  property color startColor: ColorUtils.setAlphaColor(Colors.md3.secondary, 0.3)
  property color endColor: ColorUtils.setAlphaColor(Colors.md3.primary, 0.5)

  GradientStop { position: 0.5; color: startColor }
  GradientStop { position: 1.0; color: endColor }
}