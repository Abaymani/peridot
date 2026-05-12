import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs

Rectangle {
  id: root
  signal clicked()

  required property string buttonText
  property bool toggleButton: false
  property bool checked: false
  property bool enabled: true

  property int widthPadding: 20
  property int fontSizeModifier: 8
  property color textColor: Settings.textColorOnContainer
  property int h_centerOffset: 0

  color: Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
  implicitWidth: btnText.implicitWidth + widthPadding
  opacity: toggleButton ? checked ? 1 : 0.4 : 1
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight

  Behavior on opacity {
    NumberAnimation {
      duration: 100 // 150ms is usually a sweet spot for snappy UI elements
      easing.type: Easing.InOutQuad // Gives it a natural ease-in and ease-out feel
    }
  }

  Text {
    id: btnText
    anchors.centerIn: parent
    anchors.horizontalCenterOffset: h_centerOffset
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size + fontSizeModifier
    font.weight: Looks.Fonts.weight
    text: buttonText
    color: textColor
  }

    MouseArea {
      visible: root.enabled
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true

      onClicked: {
        if (root.toggleButton) root.checked = !root.checked
        root.clicked()
      }
  }
}