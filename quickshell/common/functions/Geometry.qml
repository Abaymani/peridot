pragma Singleton
import QtQuick
import Quickshell

Singleton {
  // Top-left for a `width` x `height` box beside `point`: below and right of
  // it, flipped to the other side where it wouldn't fit, and kept inside an
  // `areaWidth` x `areaHeight` area.
  function nearPoint(point, width, height, areaWidth, areaHeight) {
    const gap = 8
    const margin = 8
    let x = point.x + gap
    if (x + width > areaWidth - margin) x = point.x - gap - width
    let y = point.y + gap
    if (y + height > areaHeight - margin) y = point.y - gap - height
    return Qt.point(
      Math.max(margin, Math.min(x, areaWidth - margin - width)),
      Math.max(margin, Math.min(y, areaHeight - margin - height)))
  }
}
