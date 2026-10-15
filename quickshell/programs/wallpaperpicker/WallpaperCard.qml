import QtQuick
import Quickshell.Widgets
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs

// A wallpaper on the carousel: its thumbnail, the switcher's ring while it's
// in the middle, and chips for the wallpaper in use and for GIFs.
//
// Only the still thumbnail goes through the ClippingRectangle. The darkening
// and the hover tint change all the time, so they're plain rounded
// rectangles on top rather than content behind its layer.
Item {
  id: root

  property var entry: null
  property bool current: false
  property real dim: 0
  property real ringOpacity: 0

  signal clicked()

  readonly property real radius: Looks.Decorations.decor.radius

  Rectangle {
    anchors.fill: parent
    anchors.margins: -6
    radius: root.radius + 6
    visible: root.ringOpacity > 0
    opacity: root.ringOpacity
    color: "transparent"
    border.width: 2
    border.color: Settings.textColorOnContainer
  }

  ClippingRectangle {
    anchors.fill: parent
    radius: root.radius
    color: Looks.Colors.md3.surface_container_lowest

    Image {
      anchors.fill: parent
      source: root.entry ? Wallpapers.fileUrl(root.entry.thumbnail) : ""
      sourceSize: Qt.size(896, 504)
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: "black"
    opacity: root.dim
  }

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: "white"
    opacity: hover.hovered ? 0.06 : 0
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.clicked()
  }

  // Like the switcher's monitor chip.
  Rectangle {
    x: 8
    y: 8
    height: 20
    radius: 10
    width: inUse.implicitWidth + 16
    visible: root.current
    color: Looks.Colors.md3.primary

    Looks.ClearText {
      id: inUse
      anchors.centerIn: parent
      text: "\u{f012c} In use"
      font.pixelSize: Looks.Fonts.size - 2
      font.bold: true
      style: Text.Normal
      color: Looks.Colors.md3.on_primary
    }
  }

  Rectangle {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 8
    height: 20
    radius: 10
    width: gif.implicitWidth + 14
    visible: root.entry?.format === "GIF"
    color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral0, 0.5)

    Looks.ClearText {
      id: gif
      anchors.centerIn: parent
      text: "GIF"
      font.pixelSize: Looks.Fonts.size - 2
      font.bold: true
      style: Text.Normal
      color: "white"
    }
  }
}
