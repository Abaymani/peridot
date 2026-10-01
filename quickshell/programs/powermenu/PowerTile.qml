import QtQuick
import qs.common.looks as Looks
import qs.common.functions
import qs.widgets
import qs

// A power menu action: glyph, label and its key.
Item {
  id: root

  property string glyph: ""
  property string label: ""
  property string key: ""
  property bool selected: false

  signal clicked()
  signal pointed()

  implicitWidth: 108
  implicitHeight: 112

  Rectangle {
    anchors.fill: parent
    radius: Looks.Decorations.decor.radius
    color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, mouseArea.containsMouse ? 0.12 : 0.07)

    Behavior on color {
      ColorAnimation { duration: 120; easing.type: Easing.OutQuad }
    }
  }

  // Faded in rather than swapped, since a gradient can't animate.
  Rectangle {
    anchors.fill: parent
    radius: Looks.Decorations.decor.radius
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

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPositionChanged: root.pointed()
    onClicked: root.clicked()
  }

  KeyCap {
    x: parent.width - width - 8
    y: 8
    text: root.key
  }

  Column {
    anchors.centerIn: parent
    anchors.verticalCenterOffset: 6
    spacing: 8

    Looks.ClearText {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.glyph
      font.pixelSize: 30
      color: Settings.textColorOnContainer
    }

    Looks.ClearText {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.label
      font.pixelSize: Looks.Fonts.size - 1
      color: Settings.textColorOnContainer
    }
  }
}
