import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.widgets
import qs.programs.switcher
import qs

// Workspace switcher: hold Alt and press Tab to step through workspaces 1-6,
// release Alt to switch. Binds are in hypr/binds.lua.
Scope {
  id: switcher

  property bool open: false
  // Delayed, so a quick Alt+Tab doesn't flash the card.
  property bool shown: false
  property bool sticky: false

  onOpenChanged: HyprWindows.tracking = open

  function step(delta: int): void {
    if (open) {
      view.step(delta)
      return
    }
    GlobalStates.isLauncherOpen = false
    GlobalStates.isControlCenterOpen = false
    sticky = false
    view.reset(delta)
    open = true
    showDelay.restart()
  }

  function commit(): void {
    if (!open) return
    const id = view.selected
    close()
    // Focusing the current workspace would go back (workspace_back_and_forth).
    if (Hyprland.focusedMonitor?.activeWorkspace?.id !== id) HyprWindows.focusWorkspace(id)
  }

  function close(): void {
    open = false
    shown = false
    showDelay.stop()
  }

  function altReleased(): void {
    if (open && !sticky) commit()
  }

  GlobalShortcut {
    name: "switcherNext"
    description: "Opens the workspace switcher, or selects the next workspace"
    onPressed: switcher.step(1)
  }

  GlobalShortcut {
    name: "switcherPrev"
    description: "Opens the workspace switcher, or selects the previous workspace"
    onPressed: switcher.step(-1)
  }

  GlobalShortcut {
    name: "switcherAlt"
    description: "Tells the workspace switcher Alt was released"
    onReleased: switcher.altReleased()
  }

  Timer {
    id: showDelay
    interval: 120
    onTriggered: switcher.shown = true
  }

  PanelWindow {
    id: panel
    visible: switcher.open
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusiveZone: 0
    color: "transparent"

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    onVisibleChanged: if (visible) view.forceActiveFocus()

    MouseArea {
      anchors.fill: parent
      onClicked: switcher.close()
    }

    FocusScope {
      anchors.fill: parent
      focus: true

      PopupCard {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Math.round(parent.height / 10)
        width: view.implicitWidth
        height: view.implicitHeight
        opacity: switcher.shown ? 1 : 0

        Behavior on opacity {
          NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        // Keeps clicks on the card from reaching the dismiss area.
        MouseArea { anchors.fill: parent }

        SwitcherView {
          id: view
          anchors.fill: parent
          focus: true
          toplevels: Hyprland.toplevels.values
          workspaces: Hyprland.workspaces.values
          monitors: Hyprland.monitors.values
          focusedMonitor: Hyprland.focusedMonitor ?? Hyprland.monitors.values[0] ?? null
          wallpaper: Settings.currentWallpaper
          previews: Settings.switcherPreviews
          capturing: switcher.open
          sticky: switcher.sticky
          maxWidth: (panel.screen?.width ?? 1920) - 80

          onInteracted: switcher.sticky = true
          onAltReleased: switcher.altReleased()
          onCommitRequested: switcher.commit()
          onCancelRequested: switcher.close()
          onWorkspaceActivated: id => {
            view.selected = id
            switcher.commit()
          }
          onWindowActivated: address => {
            switcher.close()
            HyprWindows.focusWindow(address)
          }
          onWindowMoved: (address, workspace) => HyprWindows.moveWindow(address, workspace)
        }
      }
    }
  }
}
