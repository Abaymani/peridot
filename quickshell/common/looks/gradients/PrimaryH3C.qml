import QtQuick
import qs.common.looks
import qs.common.functions

Gradient {
  orientation: Gradient.Horizontal
  property color startColor: ColorUtils.setAlphaColor(Colors.md3.primary, 0.6)
  property color midColor: '#34ffffff'
  property color endColor: ColorUtils.setAlphaColor(Colors.md3.secondary, 0.6)

  GradientStop { position: -0.2; color: startColor}
  GradientStop { position: 0.2; color: midColor}
  GradientStop { position: 1.0; color: endColor }
}