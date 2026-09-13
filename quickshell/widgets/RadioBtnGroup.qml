import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.common.looks

Rectangle {
  id: root

  // List of buttons to generate
  property var options: []
  property int selectedIndex: 0
  property bool onPrimaryBg: false
  property int fontSizeModifier: 8
  property int buttonHeight: Decorations.decor.elementHeight
  signal selectionChanged(int index)

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

        Layout.preferredHeight: root.buttonHeight
        buttonText: modelData
        fontSizeModifier: root.fontSizeModifier
        toggleButton: true
        checked: index === root.selectedIndex
        onPrimaryBg: root.onPrimaryBg

        onClicked: {
          if (root.selectedIndex !== index) {
            root.selectedIndex = index
          }
          
          selectionChanged(root.selectedIndex)
        }
      }
    }
  }
}
