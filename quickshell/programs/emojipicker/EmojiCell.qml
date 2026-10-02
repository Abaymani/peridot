import QtQuick
import qs.common.looks as Looks
import qs.common.functions
import qs

// One emoji in the picker's grid.
Item {
  id: root

  property string glyph: ""
  property bool selected: false

  signal clicked()
  // The pointer moved over the cell (see ResultRow.pointed).
  signal pointed()

  implicitWidth: 36
  implicitHeight: 36

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: Looks.Colors.md3.surface_container
    gradient: Settings.gradientBgEnabled
      ? Looks.Gradients.library[Settings.activeGradient].createObject()
      : null
    border.width: 1
    border.color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.3)
    opacity: root.selected ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }
  }

  Text {
    anchors.centerIn: parent
    text: root.glyph
    font.pixelSize: 22
    renderType: Text.NativeRendering
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPositionChanged: root.pointed()
    onClicked: root.clicked()
  }
}
