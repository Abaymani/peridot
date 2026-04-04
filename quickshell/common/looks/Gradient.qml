import QtQuick

Gradient {
  orientation: Gradient.Horizontal
  property color startColor: Colors.md3.primary
  property color midColor: '#14ffffff'
  property color endColor: Colors.md3.secondary

  GradientStop { position: -0.2; color: startColor}
  GradientStop { position: .2; color: midColor}
  GradientStop { position: 1.0; color: endColor } // Or any accent color
}