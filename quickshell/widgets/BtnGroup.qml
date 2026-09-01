import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.common.looks

Rectangle {
  id: root

  // List of buttons to generate
  property var options: []
  property bool onPrimaryBg: false
  signal newClick(int index)

  implicitHeight: buttonRow.implicitHeight
  implicitWidth: buttonRow.width
  color: "transparent"

  RowLayout {
    id: buttonRow
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

        buttonText: modelData
        onPrimaryBg: root.onPrimaryBg

        onClicked: {
          newClick(this.index)
        }
      }
    }
  }
}
