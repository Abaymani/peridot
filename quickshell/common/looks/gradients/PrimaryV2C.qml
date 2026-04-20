import QtQuick
import qs.common.looks
import qs.common.functions

Gradient {
  orientation: Gradient.Vertical
  property color startColor: ColorUtils.setAlphaColor(Colors.md3.primary, 0.3)
  property color endColor: ColorUtils.setAlphaColor(Colors.md3.secondary, 0.3)

  GradientStop { position: -0.2; color: startColor}
  GradientStop { position: 1.0; color: endColor }
}