import QtQuick
import qs.common.looks
import "../../utils/functions.js" as Utils

Gradient {
  orientation: Gradient.Vertical
  property color startColor: Utils.setAlphaColor(Colors.md3.secondary, 0.1)
  property color endColor: Utils.setAlphaColor(Colors.md3.primary, 0.18)

  GradientStop { position: 0.5; color: startColor }
  GradientStop { position: 1.0; color: endColor }
}