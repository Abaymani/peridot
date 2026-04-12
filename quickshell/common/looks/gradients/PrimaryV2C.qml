import QtQuick
import qs.common.looks
import "../../utils/functions.js" as Utils

Gradient {
  orientation: Gradient.Vertical
  property color startColor: Utils.setAlphaColor(Colors.md3.primary, 0.5)
  property color endColor: Utils.setAlphaColor(Colors.md3.secondary, 0.5)

  GradientStop { position: -0.2; color: startColor}
  GradientStop { position: 1.0; color: endColor }
}