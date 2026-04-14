import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs

Rectangle{
  id: root
  gradient: Looks.Gradients.library[Settings.activeSecondaryGradient].createObject() 
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
    color: Looks.Colors.palette.neutral60
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