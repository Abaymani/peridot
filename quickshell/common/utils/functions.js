.pragma library

// Send in an RBG color to get back an RGBA.
function setAlphaColor(colorStr, alpha) {
  var c = Qt.color(colorStr)
  return Qt.rgba(c.r, c.g, c.b, alpha)
}