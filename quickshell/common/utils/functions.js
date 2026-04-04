.pragma library

function setAlphaColor(colorStr, alpha) {
  var c = Qt.color(colorStr)
  return Qt.rgba(c.r, c.g, c.b, alpha)
}