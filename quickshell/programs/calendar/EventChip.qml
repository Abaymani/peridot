import QtQuick
import qs
import qs.common.looks as Looks

// An event: its calendar's fill (see CalendarStyle) with the calendar's
// accent down the left edge. Short ones put the time on the title's line.
Rectangle {
  id: root

  property string slot: "blue"
  property string title: ""
  property string time: ""
  readonly property bool short: height < 32

  signal clicked()

  radius: 6
  color: CalendarStyle.chipFill(slot)
  clip: true

  Rectangle {
    width: 3
    height: parent.height
    topLeftRadius: root.radius
    bottomLeftRadius: root.radius
    color: CalendarStyle.accent(root.slot)
  }

  // Hover, tinted with the text color like Button's.
  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: CalendarStyle.chipText(root.slot)
    opacity: mouseArea.containsMouse ? 0.1 : 0

    Behavior on opacity {
      NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }
  }

  Column {
    x: 8
    y: root.short ? (root.height - titleText.height) / 2 : 3
    width: root.width - 11

    Looks.ClearText {
      id: titleText
      width: parent.width
      elide: Text.ElideRight
      text: root.short && root.time !== "" ? root.title + "  " + root.time.split("–")[0] : root.title
      font.pixelSize: Looks.Fonts.size - 1
      font.weight: Font.Bold
      color: CalendarStyle.chipText(root.slot)
    }

    Looks.ClearText {
      visible: !root.short && root.time !== ""
      width: parent.width
      elide: Text.ElideRight
      text: root.time
      font.pixelSize: Looks.Fonts.size - 2
      color: CalendarStyle.chipText(root.slot)
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
