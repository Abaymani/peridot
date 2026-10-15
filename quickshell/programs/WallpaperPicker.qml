import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.widgets
import qs.programs.wallpaperpicker
import qs

// The wallpaper picker: a carousel of the wallpaper folder at the bottom of
// the focused screen, where the on-screen keyboard sits. Opened with the
// toggleWallpaperPicker shortcut; closes on Escape, on applying a wallpaper
// or on a click anywhere else.
Scope {
  Component.onCompleted: Wallpapers.init()

  PanelWindow {
    id: window

    visible: GlobalStates.isWallpaperPickerOpen
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    anchors.bottom: true
    margins.bottom: 10
    implicitWidth: Math.min(view.implicitWidth, (screen?.width ?? 1920) - 40)
    implicitHeight: view.implicitHeight
    color: "transparent"

    onVisibleChanged: if (visible) view.reset()

    HyprlandFocusGrab {
      windows: [window]
      // Waits for the surface, so the grab has something to whitelist.
      active: window.backingWindowVisible
      onCleared: GlobalStates.isWallpaperPickerOpen = false
    }

    PopupCard {
      anchors.fill: parent
      clip: true

      WallpaperPickerView {
        id: view
        anchors.fill: parent
        onCloseRequested: GlobalStates.isWallpaperPickerOpen = false
      }
    }
  }
}
