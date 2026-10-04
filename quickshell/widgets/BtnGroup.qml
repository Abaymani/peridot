import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.common.looks

Rectangle {
  id: root

  // List of buttons to generate
  property var options: []
  property bool onPrimaryBg: false
  property int widthPadding: 20
  signal newClick(int index)

  implicitHeight: buttonRow.implicitHeight
  implicitWidth: buttonRow.implicitWidth
  color: "transparent"

  // Buttons share out any width beyond their own.
  RowLayout {
    id: buttonRow
    anchors.fill: parent
    spacing: 2

    Repeater {
      model: root.options

      delegate: Button {
        required property string modelData 
        required property int index

        property bool isFirst: index === 0
        property bool isLast: index === root.options.length - 1

        topLeftRadius: isFirst ? Decorations.decor.radius : 0
        bottomLeftRadius: isFirst ? Decorations.decor.radius : 0
        topRightRadius: isLast ? Decorations.decor.radius : 0
        bottomRightRadius: isLast ? Decorations.decor.radius : 0

        Layout.fillWidth: true
        buttonText: modelData
        onPrimaryBg: root.onPrimaryBg
        widthPadding: root.widthPadding

        onClicked: {
          newClick(this.index)
        }
      }
    }
  }
}
