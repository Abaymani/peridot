import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs.common.functions
import qs

Rectangle {
  id: root
  signal clicked()

  required property string buttonText
  property bool toggleButton: false
  property bool checked: false
  property bool enabled: true
  property bool onPrimaryBg: false

  property int widthPadding: 20
  property int fontSizeModifier: 8
  property color textColor: Settings.textColorOnContainer
  property int h_centerOffset: 0

  color: Settings.gradientBgEnabled 
    ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
    : onPrimaryBg
      ? Looks.Colors.md3.secondary_container 
      : Looks.Colors.md3.surface_container
  implicitWidth: btnText.implicitWidth + widthPadding
  opacity: toggleButton ? (checked ? 1 : 0.4) : 1
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight

  Behavior on opacity {
    NumberAnimation {
      duration: 100 
      easing.type: Easing.InOutQuad
    }
  }

  Looks.ClearText {
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
        root.clicked()
      }
  }
}