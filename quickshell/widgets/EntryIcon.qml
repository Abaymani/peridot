import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.common.looks as Looks
import qs.common.functions
import qs

// A result's picture: an image file (cropped to fill the item, rounded),
// else a theme icon, else a glyph on a tinted square.
Item {
  id: root

  // Theme icon name or absolute path, like a desktop entry's Icon=.
  property string icon: ""
  // Path of an image file to show instead of the icon.
  property string image: ""
  // Nerd Font glyph for when there's neither.
  property string glyph: "\u{f08c6}"
  // Side of the icon or glyph square. An image fills the whole item.
  property int size: 28
  property real radius: Math.round(size / 4)

  // Empty when the theme has no such icon, so the glyph shows rather than
  // Qt's missing-image checkerboard.
  readonly property string iconSource: icon === "" ? ""
    : icon.startsWith("/") ? "file://" + icon
    : Quickshell.iconPath(icon, true)
  // Falls back to the icon or glyph if the image won't load, e.g. one too big
  // for Qt's 256 MB image limit.
  readonly property bool showImage: image !== "" && thumbnail.status !== Image.Error

  implicitWidth: size
  implicitHeight: size

  ClippingRectangle {
    anchors.fill: parent
    visible: root.showImage
    radius: root.radius
    color: "transparent"

    Image {
      id: thumbnail
      anchors.fill: parent
      source: root.image === "" ? "" : "file://" + root.image.split("/").map(encodeURIComponent).join("/")
      sourceSize: Qt.size(root.width * 2, root.height * 2)
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
    }
  }

  Image {
    anchors.centerIn: parent
    width: root.size
    height: root.size
    visible: !root.showImage && root.iconSource !== ""
    source: visible ? root.iconSource : ""
    sourceSize: Qt.size(root.size * 2, root.size * 2)
    fillMode: Image.PreserveAspectFit
  }

  Rectangle {
    anchors.centerIn: parent
    width: root.size
    height: root.size
    visible: !root.showImage && root.iconSource === ""
    radius: root.radius
    color: ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.35)

    Looks.ClearText {
      anchors.centerIn: parent
      text: root.glyph
      font.pixelSize: Math.round(root.size * 0.6)
      color: Settings.textColorOnContainer
    }
  }
}
