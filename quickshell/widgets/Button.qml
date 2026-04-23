import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs

Rectangle {
  id: root
  signal clicked()
  required property string buttonText
  property int widthPadding: 20
  property int fontSizeModifier: 8
  property color textColor: Settings.textColorOnContainer
  property int h_centerOffset: 0

  color: Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
  implicitWidth: btnText.implicitWidth + widthPadding
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight

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
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    onClicked: {
      root.clicked()
    }
  }
}