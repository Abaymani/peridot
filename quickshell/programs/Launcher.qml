import QtQuick
import Quickshell
import qs.widgets
import qs.programs.launcher
import qs

// App and file launcher (Super+D). The contents are in LauncherView.
Scope {
  OverlayPanel {
    open: GlobalStates.isLauncherOpen
    cardWidth: view.implicitWidth
    cardHeight: view.implicitHeight
    verticalOffset: -60
    onDismissed: GlobalStates.isLauncherOpen = false
    onOpened: view.reset()

    LauncherView {
      id: view
      anchors.fill: parent
      onCloseRequested: GlobalStates.isLauncherOpen = false
    }
  }
}
