import QtQuick
import QtQuick.Controls
import qs.common.looks as Looks
import qs

// The shell's search field: Clipboard's themed TextField with a magnifier.
// Navigation keys go to `navigator`. `keyFilter`, if set, sees each key press
// first and returns true for keys it used.
TextField {
  id: root

  property KeyNavigator navigator: null
  property var keyFilter: null

  implicitHeight: 34
  leftPadding: 34
  rightPadding: 10
  verticalAlignment: TextInput.AlignVCenter
  color: Settings.textColorOnContainer
  placeholderTextColor: Looks.Colors.palette.neutral70
  selectionColor: Looks.Colors.md3.primary
  selectedTextColor: Looks.Colors.md3.on_primary
  font.family: Looks.Fonts.family
  font.pixelSize: Looks.Fonts.size + 1

  Keys.onPressed: event => {
    if ((root.keyFilter && root.keyFilter(event)) || (root.navigator && root.navigator.handleKey(event)))
      event.accepted = true
  }

  background: Rectangle {
    radius: Looks.Decorations.decor.radius
    color: Looks.Colors.md3.surface_container
    gradient: Settings.gradientBgEnabled
      ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject()
      : null
    border.width: 1
    border.color: root.activeFocus ? Looks.Colors.md3.primary : "#00000000"

    Looks.ClearText {
      anchors.left: parent.left
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      text: "\u{f0349}"
      font.pixelSize: Looks.Fonts.size + 4
      opacity: 0.8
      color: Settings.textColorOnContainer
    }
  }
}
