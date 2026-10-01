import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.common.looks as Looks
import qs.common.functions
import qs

// A workspace in the switcher: wallpaper, windows, number and highlights.
Item {
  id: root

  property int workspaceId: 1
  property Item view
  // Bottom to top.
  property var windows: []
  property var monitor: null
  // Monitors showing this workspace, the focused one first.
  property var shownOn: []
  property bool selected: false
  property bool dropTarget: false

  // The monitor scaled to fit, centred.
  readonly property var monitorSize: view.logicalSize(monitor)
  readonly property real scale: Math.min(width / monitorSize.width, height / monitorSize.height)
  readonly property real contentX: (width - monitorSize.width * scale) / 2
  readonly property real contentY: (height - monitorSize.height * scale) / 2

  readonly property bool shown: shownOn.length > 0
  readonly property bool onFocusedMonitor: shown && shownOn[0] === view.focusedMonitor
  readonly property color ringColor: onFocusedMonitor ? Looks.Colors.md3.primary : Looks.Colors.md3.tertiary
  readonly property color ringTextColor: onFocusedMonitor ? Looks.Colors.md3.on_primary : Looks.Colors.md3.on_tertiary
  readonly property real radius: Looks.Decorations.decor.radius

  signal clicked()

  HoverHandler { id: hover }

  ClippingRectangle {
    anchors.fill: parent
    radius: root.radius
    color: Looks.Colors.md3.surface_container_lowest

    Image {
      anchors.fill: parent
      source: root.view.wallpaperUrl
      sourceSize: Qt.size(root.width * 2, root.height * 2)
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
    }

    Rectangle {
      anchors.fill: parent
      color: "black"
      opacity: root.windows.length === 0 ? 0.42 : 0.1
    }

    Looks.ClearText {
      anchors.centerIn: parent
      visible: root.windows.length === 0
      text: root.workspaceId
      font.pixelSize: Math.round(root.height * 0.42)
      font.weight: Font.DemiBold
      color: "white"
      opacity: 0.3
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onPressed: root.view.interacted()
      onClicked: root.clicked()
    }

    Repeater {
      model: ScriptModel { values: root.windows }

      WindowThumb {
        tile: root
        view: root.view
      }
    }

    Rectangle {
      anchors.fill: parent
      color: "white"
      opacity: hover.hovered && !root.view.dragThumb ? 0.06 : 0
    }

    Rectangle {
      anchors.fill: parent
      visible: root.dropTarget
      color: ColorUtils.setAlphaColor(Looks.Colors.md3.primary, 0.28)
    }
  }

  Rectangle {
    anchors.fill: parent
    anchors.margins: root.dropTarget ? 0 : -3
    radius: root.radius + 3
    visible: root.shown || root.dropTarget
    color: "transparent"
    border.width: 2
    border.color: root.dropTarget ? Looks.Colors.md3.primary : root.ringColor
  }

  // Outside the monitor ring, so both can show.
  Rectangle {
    anchors.fill: parent
    anchors.margins: -6
    radius: root.radius + 6
    visible: root.selected
    color: "transparent"
    border.width: 2
    border.color: Settings.textColorOnContainer
  }

  Rectangle {
    x: 6
    y: 6
    width: 20
    height: 20
    radius: 10
    color: root.shown ? root.ringColor : ColorUtils.setAlphaColor(Looks.Colors.palette.neutral0, 0.5)

    Looks.ClearText {
      anchors.centerIn: parent
      text: root.workspaceId
      font.pixelSize: Looks.Fonts.size - 1
      font.bold: true
      style: Text.Normal
      color: root.shown ? root.ringTextColor : "white"
    }
  }

  Rectangle {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 6
    height: 20
    radius: 10
    width: monitorName.implicitWidth + 16
    visible: root.shown
    color: root.ringColor

    Looks.ClearText {
      id: monitorName
      anchors.centerIn: parent
      text: "\u{f0379} " + root.shownOn.map(m => m.name).join(", ")
      font.pixelSize: Looks.Fonts.size - 2
      font.bold: true
      style: Text.Normal
      color: root.ringTextColor
    }
  }
}
