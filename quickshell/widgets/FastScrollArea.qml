import QtQuick
import qs

// Qt Quick's Flickable (and ListView/GridView, which extend it) has no
// property for how far a single mouse-wheel notch scrolls - the built-in
// step is fixed and, on a mouse, feels slow. This intercepts wheel events
// before they reach the target Flickable and drives contentX/contentY
// itself with a configurable multiplier instead.
//
// Must be a sibling of `target`, not a child - Flickable reparents declared
// children into its scrolling contentItem, which would drag this along
// with it and break the overlay.
MouseArea {
  id: root

  required property Flickable target
  // Defaults to the "Shell scroll speed" setting (Appearance page) so every
  // scrollable stays in sync; pass an explicit value to override per-instance.
  property real speedMultiplier: Settings.scrollSpeedMultiplier

  acceptedButtons: Qt.NoButton
  hoverEnabled: false

  onWheel: (wheel) => {
    if (wheel.angleDelta.y !== 0) {
      const maxY = Math.max(0, target.contentHeight - target.height)
      target.contentY = Math.max(0, Math.min(maxY, target.contentY - wheel.angleDelta.y * root.speedMultiplier / 120))
    }
    if (wheel.angleDelta.x !== 0) {
      const maxX = Math.max(0, target.contentWidth - target.width)
      target.contentX = Math.max(0, Math.min(maxX, target.contentX - wheel.angleDelta.x * root.speedMultiplier / 120))
    }
    wheel.accepted = true
  }
}
