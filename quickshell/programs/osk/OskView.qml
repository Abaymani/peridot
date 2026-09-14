import QtQuick
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

// The on-screen keyboard's card: a header (title, layout, function row, pin,
// close) over the key rows, every row 15 units wide.
PopupCard {
  id: root

  signal closeRequested()

  readonly property int gap: 5
  readonly property int keyHeight: 46
  readonly property var rows: (Settings.oskFunctionRow ? [Osk.functionRow] : []).concat(Osk.layout.rows)
  // The width of a 1-unit key.
  readonly property real unit: (width - 20 - 14 * gap) / 15

  implicitWidth: 1120
  implicitHeight: column.implicitHeight + 20

  Column {
    id: column
    x: 10
    y: 10
    width: root.width - 20
    spacing: root.gap

    Item {
      width: parent.width
      height: 28

      Looks.ClearText {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: Osk.ready ? "\u{f030c}  Keyboard" : "\u{f0026}  ydotool isn't running, so keys can't be sent - see Settings › Keyboard"
        font.pixelSize: Looks.Fonts.size - 1
        opacity: Osk.ready ? 0.7 : 1
        color: Osk.ready ? Settings.textColorOnContainer : Looks.Colors.md3.error
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Button {
          height: 24
          buttonText: Osk.layout.short
          fontSizeModifier: -1
          widthPadding: 16
          onClicked: Osk.cycleLayout()
        }

        Button {
          height: 24
          buttonText: "Fn"
          toggleButton: true
          checked: Settings.oskFunctionRow
          fontSizeModifier: -1
          widthPadding: 16
          onClicked: {
            Settings.oskFunctionRow = !Settings.oskFunctionRow
            Settings.store.saveKey("oskFunctionRow")
          }
        }

        // Pinned, windows make room for the keyboard instead of going under it.
        Button {
          height: 24
          buttonText: "\u{f0403}"
          toggleButton: true
          checked: Settings.oskPinned
          fontSizeModifier: 1
          widthPadding: 16
          onClicked: {
            Settings.oskPinned = !Settings.oskPinned
            Settings.store.saveKey("oskPinned")
          }
        }

        Button {
          height: 24
          buttonText: "\u{f0156}"
          fontSizeModifier: 1
          widthPadding: 16
          onClicked: root.closeRequested()
        }
      }
    }

    Repeater {
      model: root.rows

      delegate: Row {
        id: keyRow
        required property var modelData
        spacing: root.gap

        Repeater {
          model: keyRow.modelData

          delegate: OskKey {
            required property var modelData
            readonly property real units: modelData.width || 1

            key: modelData
            width: root.unit * units + root.gap * (units - 1)
            height: root.keyHeight
            rowHeight: root.keyHeight
            rowGap: root.gap
          }
        }
      }
    }
  }
}
