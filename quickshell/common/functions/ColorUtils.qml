pragma Singleton
import Quickshell

Singleton{
  /**
  * Send in an RBG color to get back an RGBA.
  * @param {string} colorStr
  * @param {float} alpha
  * @returns {color}
  */
  function setAlphaColor(colorStr, alpha) {
    var c = Qt.color(colorStr)
    return Qt.rgba(c.r, c.g, c.b, alpha)
  }
}
