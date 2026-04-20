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
  
  Text {
    text: ">"
    color: Settings.textColorNotContainer
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size
    Layout.fillWidth: false

    renderTypeQuality: 16 // Helps with legibility on light wallpapers
    renderType: Text.NativeRendering
    style: Text.Outline
    styleColor: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral0, 0.1)
  }

  Text {
    id: titleText
    color: Settings.textColorNotContainer
    text: activeWindow?.title ?? "Desktop"
    
    Layout.fillWidth: true      
    Layout.maximumWidth: 350    
    
    elide: Text.ElideRight
    font.family: Looks.Fonts.family
    font.pixelSize: Looks.Fonts.size
    font.weight: Looks.Fonts.weight

    renderTypeQuality: 16 // Helps with legibility on light wallpapers
    renderType: Text.NativeRendering
    style: Text.Outline
    styleColor: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral0, 0.1)
  }
}