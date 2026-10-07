import QtQuick
import QtQuick.Layouts
import qs
import qs.widgets
import qs.common.looks as Looks

// The month or week shown, an optional week chip, and ‹ Today › as one group.
RowLayout {
  id: root

  property string title: ""
  property string chip: ""

  signal previous()
  signal today()
  signal next()

  spacing: 8

  Looks.ClearText {
    text: root.title
    font.pixelSize: Looks.Fonts.size + 3
    font.weight: Font.Bold
    color: Settings.textColorOnContainer
  }

  KeyCap {
    visible: root.chip !== ""
    text: root.chip
  }

  Item { Layout.fillWidth: true }

  // A BtnGroup, with a text label in the middle.
  RowLayout {
    spacing: 2

    Button {
      Layout.preferredHeight: Looks.Decorations.decor.elementHeight
      buttonText: "\u{f0141}"
      fontSizeModifier: 2
      widthPadding: 14
      topRightRadius: 0
      bottomRightRadius: 0
      onClicked: root.previous()
    }

    Button {
      Layout.preferredHeight: Looks.Decorations.decor.elementHeight
      buttonText: "Today"
      fontSizeModifier: 0
      widthPadding: 18
      radius: 0
      onClicked: root.today()
    }

    Button {
      Layout.preferredHeight: Looks.Decorations.decor.elementHeight
      buttonText: "\u{f0142}"
      fontSizeModifier: 2
      widthPadding: 14
      topLeftRadius: 0
      bottomLeftRadius: 0
      onClicked: root.next()
    }
  }
}
