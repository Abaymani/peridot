import QtQuick

// The bar's left, centre and right sections, laid out per BarWidgets.layout.
Item {
  id: root

  readonly property int spacing: 8
  readonly property alias leftSection: leftZone
  readonly property alias centerSection: centerZone
  readonly property alias rightSection: rightZone

  BarZone {
    id: leftZone
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    widgets: BarWidgets.layout.left
  }

  BarZone {
    id: rightZone
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    widgets: BarWidgets.layout.right
  }

  // Centred on the bar, but pushed aside rather than over the other sections.
  BarZone {
    id: centerZone
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    x: Math.max(leftZone.width + root.spacing,
      Math.min(Math.round((root.width - width) / 2), rightZone.x - root.spacing - width))
    widgets: BarWidgets.layout.center
  }
}
