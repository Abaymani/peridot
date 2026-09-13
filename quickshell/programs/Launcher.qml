import QtQuick
import Quickshell
import qs.widgets
import qs.programs.launcher
import qs

// App, file and clipboard launcher. Super+D opens it on apps; Super+V and
// the control center's clipboard button open it on the clipboard. The
// contents are in LauncherView.
Scope {
  id: launcher

  // The mode the launcher opens on next; see onLauncherModeRequested.
  property int openingMode: 0

  Connections {
    target: GlobalStates

    // Opens on `mode`, switches to it, or closes if it's already showing.
    function onLauncherModeRequested(mode) {
      if (!GlobalStates.isLauncherOpen) {
        launcher.openingMode = mode
        GlobalStates.isLauncherOpen = true
      } else if (view.mode === mode) {
        GlobalStates.isLauncherOpen = false
      } else {
        view.setMode(mode)
      }
    }
  }

  OverlayPanel {
    open: GlobalStates.isLauncherOpen
    cardWidth: view.implicitWidth
    cardHeight: view.implicitHeight
    verticalOffset: -60
    onDismissed: GlobalStates.isLauncherOpen = false
    onOpened: {
      view.reset(launcher.openingMode)
      launcher.openingMode = 0
    }

    LauncherView {
      id: view
      anchors.fill: parent
      onCloseRequested: GlobalStates.isLauncherOpen = false
    }
  }
}
