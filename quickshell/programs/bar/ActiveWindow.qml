import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs.common.functions
import qs

RowLayout {
  id: root
  readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

  spacing: 6 
  
  Looks.ClearText {
    text: ">"
    color: Settings.textColorNotContainer
    Layout.fillWidth: false

    renderTypeQuality: 16 // Helps with legibility on light wallpapers
  }

  Looks.ClearText {
    id: titleText
    color: Settings.textColorNotContainer
    text: activeWindow?.title ?? "Desktop"
    
    Layout.fillWidth: true      
    Layout.maximumWidth: 350    
    
    elide: Text.ElideRight

    renderTypeQuality: 16 // Helps with legibility on light wallpapers
  }
}