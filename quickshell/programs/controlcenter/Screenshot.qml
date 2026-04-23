import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs

Rectangle{
  id: root
  color: Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
  implicitWidth: screenshotIcon.implicitWidth + 17
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight

  Text {
    id: screenshotIcon
    anchors.centerIn: parent
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size+4
    font.weight: Looks.Fonts.weight
    text: ""
    color: Settings.textColorOnContainer
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    onClicked: {
      Quickshell.execDetached(["sh", "-c", "~/peridot/peridot/scripts/screenshot.sh"]);
    }
  }
}