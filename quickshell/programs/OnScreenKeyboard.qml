import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs.programs.osk
import qs

Scope {
  id: osk

  // Opened from the lockscreen, so it closes again on unlock.
  property bool openedOnLock: false

  Connections {
    target: GlobalStates

    function onIsOskOpenChanged() {
      if (GlobalStates.isOskOpen) {
        Osk.refresh()
      } else {
        Osk.releaseAll()
        osk.openedOnLock = false
      }
    }

    function onScreenLockedChanged() {
      if (!GlobalStates.screenLocked && osk.openedOnLock) GlobalStates.isOskOpen = false
    }
  }

  PanelWindow {
    visible: GlobalStates.isOskOpen
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "peridot-osk"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Settings.oskPinned ? implicitHeight + margins.bottom : 0
    anchors.bottom: true
    margins.bottom: 10
    implicitWidth: Math.min(view.implicitWidth, (screen?.width ?? 1920) - 40)
    implicitHeight: view.implicitHeight
    color: "transparent"

    OskView {
      id: view
      anchors.fill: parent
      onCloseRequested: GlobalStates.isOskOpen = false
    }
  }

  // The lockscreen's Keyboard button.
  PanelWindow {
    visible: GlobalStates.screenLocked && !GlobalStates.isOskOpen
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "peridot-osk"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors.bottom: true
    margins.bottom: 28
    implicitWidth: lockButton.implicitWidth
    implicitHeight: lockButton.implicitHeight
    color: "transparent"

    PopupCard {
      id: lockButton
      anchors.fill: parent
      implicitWidth: lockLabel.implicitWidth + 36
      implicitHeight: 40
      radius: height / 2

      Looks.ClearText {
        id: lockLabel
        anchors.centerIn: parent
        text: "\u{f030c}  Keyboard"
        color: Settings.textColorOnContainer
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          osk.openedOnLock = true
          GlobalStates.isOskOpen = true
        }
      }
    }
  }
}
