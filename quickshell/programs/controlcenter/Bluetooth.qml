import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs

Rectangle{
  gradient: Looks.Gradients.library[Settings.activeSecondaryGradient].createObject() 
  implicitWidth: bluetoothIcon.implicitWidth + 20
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight

  Text {
    id: bluetoothIcon
    anchors.centerIn: parent
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size+8
    font.weight: Looks.Fonts.weight
    text: "󰂯"
    color: Looks.Colors.palette.neutral100
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    onClicked: {
      Quickshell.execDetached(["hyprctl", "dispatch", "exec", "blueman-manager"]);
    }
  }
}