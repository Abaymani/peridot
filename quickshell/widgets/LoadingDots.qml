import QtQuick
import qs.common.looks as Looks
import qs

// "..." but animated!
Row {
  id: root

  property color color: Settings.textColorOnContainer
  property int pixelSize: Looks.Fonts.size
  property int shown: 1

  onVisibleChanged: if (visible) shown = 1

  Repeater {
    model: 3

    Looks.ClearText {
      required property int index

      text: "."
      color: root.color
      font.pixelSize: root.pixelSize
      opacity: root.shown > index ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
      }
    }
  }

  Timer {
    interval: 300
    running: root.visible
    repeat: true
    onTriggered: root.shown = (root.shown + 1) % 4
  }
}
