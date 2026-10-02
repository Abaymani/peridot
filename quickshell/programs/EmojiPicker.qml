import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.common.functions
import qs.services
import qs.widgets
import qs.programs.emojipicker
import qs

// Emoji picker, opened beside the pointer with Super+F6. Picking an emoji
// copies it.
Scope {
  id: picker

  // Set once the pointer's been found, which happens each time it opens.
  property bool placed: false
  property string monitorName: ""
  property point cardPosition: Qt.point(-1, -1)

  Connections {
    target: GlobalStates

    function onIsEmojiPickerOpenChanged() {
      picker.placed = false
      if (GlobalStates.isEmojiPickerOpen) pointer.running = true
    }
  }

  Process {
    id: pointer
    command: ["hyprctl", "cursorpos", "-j"]
    stdout: StdioCollector { id: pointerOutput }

    onExited: (exitCode, exitStatus) => {
      let position = null
      try {
        position = JSON.parse(pointerOutput.text)
      } catch (e) {
        // Opens centred on the focused monitor instead.
      }
      const monitor = position && Hyprland.monitors.values.find(m =>
        position.x >= m.x && position.x < m.x + m.width / m.scale
        && position.y >= m.y && position.y < m.y + m.height / m.scale)
      if (monitor) {
        const turned = (monitor.lastIpcObject?.transform ?? 0) % 2 === 1
        const width = (turned ? monitor.height : monitor.width) / monitor.scale
        const height = (turned ? monitor.width : monitor.height) / monitor.scale
        picker.monitorName = monitor.name
        picker.cardPosition = Geometry.nearPoint(Qt.point(position.x - monitor.x, position.y - monitor.y),
          view.implicitWidth, view.implicitHeight, width, height)
      } else {
        picker.monitorName = Hyprland.focusedMonitor?.name ?? ""
        picker.cardPosition = Qt.point(-1, -1)
      }
      picker.placed = true
    }
  }

  OverlayPanel {
    open: GlobalStates.isEmojiPickerOpen && picker.placed
    screen: Quickshell.screens.find(s => s.name === picker.monitorName) ?? null
    // Covers the whole monitor, bar included, so cardPosition is in monitor coordinates.
    exclusionMode: ExclusionMode.Ignore
    cardWidth: view.implicitWidth
    cardHeight: view.implicitHeight
    cardPosition: picker.cardPosition
    onDismissed: GlobalStates.isEmojiPickerOpen = false
    onOpened: view.reset()

    EmojiPickerView {
      id: view
      anchors.fill: parent
      onPicked: emoji => {
        GlobalStates.isEmojiPickerOpen = false
        Emoji.copy(emoji)
      }
    }
  }
}
