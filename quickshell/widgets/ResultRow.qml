import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs

// A search result as a list row: picture, then title over subtitle (both
// StyledText, for match highlights). Anything declared inside goes at the
// row's end, e.g. badges or small buttons.
Item {
  id: root

  property alias icon: picture.icon
  property alias image: picture.image
  property alias glyph: picture.glyph
  property string title: ""
  property string subtitle: ""
  property bool selected: false
  readonly property bool hovered: mouseArea.containsMouse
  default property alias trailing: trailingRow.data

  signal clicked()
  // The pointer moved over the row. Unlike hovering, this doesn't fire when
  // the list scrolls under a pointer that's standing still.
  signal pointed()

  implicitHeight: 42

  Rectangle {
    anchors.fill: parent
    visible: root.selected
    radius: Looks.Decorations.decor.radius - 2
    color: Looks.Colors.md3.surface_container
    gradient: Settings.gradientBgEnabled
      ? Looks.Gradients.library[Settings.activeGradient].createObject()
      : null
    border.width: 1
    border.color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.25)
  }

  // Below the content, so small buttons declared inside get their own clicks.
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPositionChanged: root.pointed()
    onClicked: root.clicked()
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 10
    spacing: 10

    EntryIcon {
      id: picture
      size: 28
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      Looks.ClearText {
        Layout.fillWidth: true
        text: root.title
        textFormat: Text.StyledText
        font.pixelSize: Looks.Fonts.size + 1
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
      }

      Looks.ClearText {
        Layout.fillWidth: true
        visible: root.subtitle !== ""
        text: root.subtitle
        textFormat: Text.StyledText
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.6
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
      }
    }

    RowLayout {
      id: trailingRow
      spacing: 8
    }
  }
}
