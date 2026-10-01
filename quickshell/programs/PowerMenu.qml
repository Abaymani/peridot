import QtQuick
import Quickshell
import qs.services
import qs.widgets
import qs.programs.powermenu
import qs

// Lock, suspend, log out, reboot and shut down. Opened from the bar's power icon.
Scope {
  OverlayPanel {
    id: panel
    open: GlobalStates.isPowerMenuOpen
    cardWidth: view.implicitWidth
    cardHeight: view.implicitHeight
    verticalOffset: -Math.round(panel.height / 10)
    onDismissed: GlobalStates.isPowerMenuOpen = false
    onOpened: view.reset()

    PowerMenuView {
      id: view
      anchors.fill: parent
      onActivated: action => {
        GlobalStates.isPowerMenuOpen = false
        Session.run(action)
      }
    }
  }
}
