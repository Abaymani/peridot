import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
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

      KeyCap {
        text: hint.modelData[0]
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
