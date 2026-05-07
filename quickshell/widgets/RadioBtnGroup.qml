import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.common.looks

Rectangle {
  id: root

  // List of buttons to generate
  property var options: []
  property int selectedIndex: 0
  property color btnColor: Colors.md3.secondary_container
  signal selectionChanged(int index, string value)

  implicitHeight: buttonRow.implicitHeight
  color: "transparent"

  RowLayout {
    id: buttonRow
    spacing: 1

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
        checked: index === root.selectedIndex
        color: root.btnColor

        onClicked: {
          console.log(modelData)
          if (root.selectedIndex !== index) {
            root.selectedIndex = index
            root.selectionChanged(index, modelData)
          }
        }
      }
    }
  }
}
