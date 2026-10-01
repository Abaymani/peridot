import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs.widgets
import qs

// A window on a workspace tile: its capture and app icon. Click to focus it,
// drag it to another tile to move it there.
Item {
  id: root

  required property var modelData
  // Plain Items: QML rejects types that reference each other.
  property Item tile
  property Item view

  readonly property var toplevel: modelData
  readonly property var ipc: toplevel.lastIpcObject ?? {}
  readonly property var entry: Apps.forClass(ipc.class)
  readonly property bool hovered: area.containsMouse && !view.dragThumb
  readonly property bool previewing: view.capturing && view.previews !== "off" && !!toplevel.wayland

  // Animated in monitor coordinates, so windows glide when they re-tile but
  // not when the tiles resize.
  property real monitorX: (ipc.at?.[0] ?? 0) - (tile.monitor?.x ?? 0)
  property real monitorY: (ipc.at?.[1] ?? 0) - (tile.monitor?.y ?? 0)
  property real monitorWidth: ipc.size?.[0] ?? 0
  property real monitorHeight: ipc.size?.[1] ?? 0

  Behavior on monitorX { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
  Behavior on monitorY { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
  Behavior on monitorWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
  Behavior on monitorHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

  x: tile.contentX + monitorX * tile.scale
  y: tile.contentY + monitorY * tile.scale
  width: monitorWidth * tile.scale
  height: monitorHeight * tile.scale

  ClippingRectangle {
    anchors.fill: parent
    radius: 3
    color: Looks.Colors.md3.surface_container_high

    Loader {
      anchors.fill: parent
      active: root.previewing

      sourceComponent: ScreencopyView {
        captureSource: root.toplevel.wayland
        live: root.view.previews === "live"
      }
    }

    Rectangle {
      anchors.fill: parent
      color: Settings.textColorOnContainer
      opacity: root.hovered ? 0.1 : 0
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: 3
    color: "transparent"
    border.width: 1.5
    border.color: Settings.textColorOnContainer
    opacity: root.hovered ? 0.8 : 0
  }

  Rectangle {
    anchors.centerIn: parent
    width: icon.size + 12
    height: width
    radius: width / 2
    color: ColorUtils.setAlphaColor(Looks.Colors.md3.surface_container, 0.72)
    visible: root.width > width && root.height > height
  }

  EntryIcon {
    id: icon
    anchors.centerIn: parent
    size: Math.round(Math.max(16, Math.min(40, Math.min(root.width, root.height) * 0.35)))
    icon: root.entry?.icon ?? root.ipc.class ?? ""
    visible: root.width > size && root.height > size
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    preventStealing: true
    cursorShape: root.view.dragThumb === root ? Qt.ClosedHandCursor : Qt.PointingHandCursor

    property point pressPoint
    // Stays set if the drag is cancelled, so the release isn't a click.
    property bool dragged: false

    onPressed: mouse => {
      pressPoint = Qt.point(mouse.x, mouse.y)
      dragged = false
      root.view.interacted()
    }

    onPositionChanged: mouse => {
      if (!pressed) return
      if (!dragged && Math.hypot(mouse.x - pressPoint.x, mouse.y - pressPoint.y) > 6) {
        dragged = true
        root.view.beginDrag(root, pressPoint)
      }
      if (root.view.dragThumb === root) root.view.dragPos = mapToItem(root.view, mouse.x, mouse.y)
    }

    onReleased: if (dragged && root.view.dragThumb === root) root.view.drop()
    onClicked: if (!dragged) root.view.windowActivated(root.toplevel.address)
    onCanceled: if (root.view.dragThumb === root) root.view.cancelDrag()
  }
}
