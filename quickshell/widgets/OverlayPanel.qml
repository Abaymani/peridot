import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// A PopupCard over the focused screen, like the clipboard's: it takes the
// keyboard while open, and closes on Escape or a click outside the card. Bind
// `open` to a GlobalStates flag and clear the flag in onDismissed:
//
//     OverlayPanel {
//       open: GlobalStates.isFooOpen
//       onDismissed: GlobalStates.isFooOpen = false
//       onOpened: fooView.focusInput()
//       cardWidth: 500
//       cardHeight: 400
//       FooView { id: fooView; anchors.fill: parent }
//     }
PanelWindow {
  id: root

  property bool open: false
  property real cardWidth: 400
  property real cardHeight: 300
  // Moves the card up (negative) or down from the screen's center.
  property real verticalOffset: 0
  default property alias content: card.data

  signal dismissed()
  // Each time the panel appears - focus your input here.
  signal opened()

  visible: open
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

  onVisibleChanged: if (visible) opened()

  MouseArea {
    anchors.fill: parent
    onClicked: root.dismissed()
  }

  // Escape reaches this from whichever child has focus, unless it used it.
  FocusScope {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: root.dismissed()

    PopupCard {
      id: card
      anchors.centerIn: parent
      anchors.verticalCenterOffset: root.verticalOffset
      // No Behavior here: content that animates its own size (like the
      // launcher's details pane) would get a card lagging behind it.
      width: root.cardWidth
      height: root.cardHeight
      clip: true

      // Keeps clicks on the card from reaching the dismiss area.
      MouseArea { anchors.fill: parent }
    }
  }
}
