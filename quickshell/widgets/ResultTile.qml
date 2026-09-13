import QtQuick
import qs.common.looks as Looks
import qs.common.functions
import qs

// A result as a grid tile: icon over a one-line name, on a faint fill that
// lights up when `selected`.
Item {
  id: root

  property alias icon: picture.icon
  property alias glyph: picture.glyph
  property string title: ""
  property bool selected: false

  signal clicked()
  // The pointer moved over the tile (see ResultRow.pointed).
  signal pointed()

  implicitHeight: 72

  Rectangle {
    anchors.fill: parent
    radius: Looks.Decorations.decor.radius
    color: root.selected
      ? Looks.Colors.md3.surface_container
      : ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, mouseArea.containsMouse ? 0.12 : 0.07)
    gradient: root.selected && Settings.gradientBgEnabled
      ? Looks.Gradients.library[Settings.activeGradient].createObject()
      : null
    border.width: root.selected ? 1 : 0
    border.color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.3)
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPositionChanged: root.pointed()
    onClicked: root.clicked()
  }

  Column {
    anchors.centerIn: parent
    spacing: 6

    EntryIcon {
      id: picture
      anchors.horizontalCenter: parent.horizontalCenter
      size: 32
    }

    Looks.ClearText {
      width: root.width - 10
      horizontalAlignment: Text.AlignHCenter
      text: root.title
      elide: Text.ElideRight
      font.pixelSize: Looks.Fonts.size - 2
      color: Settings.textColorOnContainer
    }
  }
}
