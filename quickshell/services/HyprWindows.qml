pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Window focus and move dispatches. Hyprland only reports window geometry
// (lastIpcObject) on refresh; while `tracking`, window events trigger one.
Singleton {
  id: root

  property bool tracking: false

  readonly property var geometryEvents: [
    "openwindow", "closewindow", "movewindowv2", "changefloatingmode", "fullscreen",
    "workspacev2", "moveworkspacev2", "monitoraddedv2", "monitorremovedv2"
  ]

  onTrackingChanged: if (tracking) refresh()

  function refresh(): void {
    Hyprland.refreshToplevels()
  }

  // `address` is HyprlandToplevel.address: hex without the 0x.
  function focusWindow(address: string): void {
    Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${address}" })`)
  }

  function focusWorkspace(id: int): void {
    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`)
  }

  function moveWindow(address: string, workspace: int): void {
    Hyprland.dispatch(`hl.dsp.window.move({ workspace = ${workspace}, follow = false, window = "address:0x${address}" })`)
  }

  Connections {
    target: Hyprland
    enabled: root.tracking

    function onRawEvent(event) {
      if (root.geometryEvents.includes(event.name)) debounce.restart()
    }
  }

  Timer {
    id: debounce
    interval: 40
    onTriggered: root.refresh()
  }
}
