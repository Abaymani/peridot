import QtQuick
import qs.common.looks
import qs.common.functions

Gradient {
  orientation: Gradient.Vertical
  property color startColor: ColorUtils.setAlphaColor(Colors.md3.primary, 0.5)
  property color midColor: '#34ffffff'
  property color endColor: ColorUtils.setAlphaColor(Colors.md3.secondary, 0.5)

  GradientStop { position: -0.2; color: startColor}
  GradientStop { position: 0.2; color: midColor}
  GradientStop { position: 1.0; color: endColor }
}