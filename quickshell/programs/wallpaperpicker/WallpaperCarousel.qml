import QtQuick
import qs.common.looks as Looks
import qs

// Wallpapers on a carousel that wraps around: the focused one large in the
// middle, the others shrinking, darkening and fading toward the edges. Moves a
// card per wheel notch or arrow press, follows drags and settles on the
// nearest card when let go.
Item {
  id: root

  property var model: []
  // The wallpaper in use, which gets a chip.
  property string currentPath: ""

  readonly property int count: model.length
  // Fractional and unbounded: card i is in the middle at any position that is
  // i modulo count.
  property real position: 0
  readonly property int currentIndex: count === 0 ? -1 : wrap(Math.round(position))
  readonly property var currentEntry: currentIndex >= 0 ? model[currentIndex] : null

  // The middle card; the others are scaled down from it.
  property real cardWidth: 448
  property real cardHeight: 252
  property real gap: 18

  // Per whole step from the middle: scale, opacity and darkening.
  readonly property var scales: [1, 0.62, 0.4, 0.3, 0.25]
  readonly property var opacities: [1, 1, 0.7, 0, 0]
  readonly property var dims: [0, 0.35, 0.5, 0.6, 0.6]
  // Centre-to-centre distance from the middle, with a gap between cards.
  readonly property var offsets: {
    const result = [0]
    for (let i = 1; i < scales.length; i++)
      result.push(result[i - 1] + cardWidth * (scales[i - 1] + scales[i]) / 2 + gap)
    return result
  }
  // Steps from the middle that get a card: up to three each way, but no
  // wallpaper twice when there are only a few.
  readonly property var slots: {
    const result = []
    for (let k = -Math.min(3, Math.floor((count - 1) / 2)); k <= Math.min(3, Math.ceil((count - 1) / 2)); k++)
      result.push(k)
    return result
  }

  // Where the last move was headed, so quick presses add up instead of
  // starting over from mid-animation.
  property real goal: 0
  property bool dragging: false

  // The middle card was clicked.
  signal activated(int index)

  implicitHeight: cardHeight + 20

  Behavior on position {
    enabled: !root.dragging
    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
  }

  function wrap(index: int): int {
    return ((index % count) + count) % count
  }

  // Between the per-step values, for a card `distance` steps out.
  function lerp(values, distance: real): real {
    const step = Math.min(Math.floor(distance), values.length - 2)
    const t = Math.min(distance - step, 1)
    return values[step] + (values[step + 1] - values[step]) * t
  }

  function move(steps: int): void {
    if (count === 0) return
    goal = Math.round(goal) + steps
    position = goal
  }

  // Turns the short way round to `index`.
  function select(index: int): void {
    if (count === 0) return
    let delta = wrap(index - wrap(Math.round(goal)))
    if (delta > count / 2) delta -= count
    move(delta)
  }

  // Puts `index` in the middle without animating.
  function jumpTo(index: int): void {
    dragging = true
    goal = Math.max(0, index)
    position = goal
    dragging = false
  }

  Repeater {
    model: root.count > 0 ? root.slots : []

    WallpaperCard {
      required property int modelData

      readonly property int virtualIndex: Math.round(root.position) + modelData
      readonly property real offset: virtualIndex - root.position
      readonly property real distance: Math.abs(offset)

      entry: root.model[root.wrap(virtualIndex)] ?? null
      current: entry !== null && entry.path === root.currentPath
      width: root.cardWidth
      height: root.cardHeight
      x: (root.width - width) / 2 + Math.sign(offset) * root.lerp(root.offsets, distance)
      y: (root.height - height) / 2
      scale: root.lerp(root.scales, distance)
      opacity: root.lerp(root.opacities, distance)
      z: 10 - distance
      dim: root.lerp(root.dims, distance)
      ringOpacity: Math.max(0, 1 - distance * 2)

      onClicked: {
        if (distance < 0.5) root.activated(root.wrap(virtualIndex))
        else root.move(Math.round(offset))
      }
    }
  }

  WheelHandler {
    property real pending: 0

    onWheel: event => {
      // Mouse wheels send 120 per notch; touchpads send smaller steps that add up.
      pending += event.angleDelta.y !== 0 ? -event.angleDelta.y : event.angleDelta.x
      const steps = Math.trunc(pending / 120)
      if (steps !== 0) {
        pending -= steps * 120
        root.move(steps)
      }
    }
  }

  DragHandler {
    target: null
    yAxis.enabled: false

    property real start: 0

    onActiveChanged: {
      if (active) {
        start = root.position
        root.dragging = true
      } else {
        root.dragging = false
        root.goal = Math.round(root.position)
        root.position = root.goal
      }
    }
    onTranslationChanged: if (active) root.position = start - translation.x / root.offsets[1]
  }
}
