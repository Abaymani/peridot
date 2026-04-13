import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks

RowLayout {
  id: root
  readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

  spacing: 6 
  
  Text {
    text: ">"
    color: Looks.Colors.palette.neutral100
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size
    Layout.fillWidth: false
  }

  Text {
    id: titleText
    color: Looks.Colors.palette.neutral100
    text: activeWindow?.title ?? "Desktop"
    
    Layout.fillWidth: true      
    Layout.maximumWidth: 350    
    
    elide: Text.ElideRight
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size
    font.weight: Looks.Fonts.weight
  }
}