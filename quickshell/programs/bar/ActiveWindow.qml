import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks

// If this widget ITSELF is a RowLayout
RowLayout {
  id: root
  readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
  
  // Set the spacing between the ">" and the title
  spacing: 6 
  
  Text {
    text: ">"
    color: Looks.Colors.palette.neutral100
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size
    Layout.fillWidth: false // The ">" doesn't need to stretch
  }

  Text {
    id: titleText
    color: Looks.Colors.palette.neutral100
    text: activeWindow?.title ?? "Desktop"
    
    // THE IMPORTANT PARTS:
    Layout.fillWidth: true      
    Layout.maximumWidth: 350    
    
    elide: Text.ElideRight
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size
    font.weight: Looks.Fonts.weight
  }
}