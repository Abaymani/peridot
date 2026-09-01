import QtQuick
import qs.common.looks
import qs.common.functions

Gradient {
  orientation: Gradient.Vertical
  property color startColor: ColorUtils.setAlphaColor(Colors.md3.secondary, 0.5)

  GradientStop { position: 0; color: startColor }
}