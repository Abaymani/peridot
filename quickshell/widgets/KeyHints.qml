import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs

// A row of keyboard hints: each a key cap, then what the key does.
//
//     KeyHints { keys: [["↑↓", "select"], ["↵", "open"]] }
RowLayout {
  id: root

  property var keys: []

  spacing: 14

  Repeater {
    model: root.keys

    delegate: RowLayout {
      id: hint
      required property var modelData
      spacing: 5

      Rectangle {
        implicitWidth: cap.implicitWidth + 10
        implicitHeight: 18
        radius: 5
        color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.12)

        Looks.ClearText {
          id: cap
          anchors.centerIn: parent
          text: hint.modelData[0]
          font.pixelSize: Looks.Fonts.size - 2
          color: Settings.textColorOnContainer
        }
      }

      Looks.ClearText {
        text: hint.modelData[1]
        font.pixelSize: Looks.Fonts.size - 2
        opacity: 0.65
        color: Settings.textColorOnContainer
      }
    }
  }
}
