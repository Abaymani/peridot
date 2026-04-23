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
  implicitWidth: settingsIcon.implicitWidth + 17
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight

  Text {
    id: settingsIcon
    anchors.centerIn: parent
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size+6
    font.weight: Looks.Fonts.weight
    text: ""
    color: Looks.Colors.md3.on_secondary
  }

  MouseArea {
    anchors.fill: parent
    //cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    onClicked: {
      console.log("Settings app doesn't exist yet! :(")
    }
  }
}