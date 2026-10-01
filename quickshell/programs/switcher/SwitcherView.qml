import QtQuick
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

// The switcher's contents: workspaces 1-6 as tiles, and a footer with key
// hints. Takes Hyprland's objects as properties, so a bench can pass
// look-alikes.
Item {
  id: root

  property var toplevels: []
  property var workspaces: []
  property var monitors: []
  property var focusedMonitor: null
  property string wallpaper: ""
  // "live", "still" or "off".
  property string previews: "live"
  property bool capturing: false
  // Set once the mouse is used; releasing Alt then no longer switches.
  property bool sticky: false
  property real maxWidth: 1800

  readonly property int count: 6
  property int selected: 1

  property Item dragThumb: null
  property point dragPos
  property point grabOffset
  property int dragFrom: 0
  readonly property int dropTarget: dragThumb ? tileAt(dragPos) : 0

  // Address -> workspace for dropped windows until Hyprland reports the move.
  property var pendingMoves: ({})

  signal workspaceActivated(int id)
  signal windowActivated(string address)
  signal windowMoved(string address, int workspace)
  signal commitRequested()
  signal cancelRequested()
  signal interacted()
  signal altReleased()

  readonly property real pad: 18
  readonly property real gap: 14
  readonly property real footerGap: 16
  readonly property real tileWidth: Math.floor(Math.min(272, (maxWidth - pad * 2 - gap * (count - 1)) / count))
  // Shaped like the focused monitor, within 21:9 to 4:3.
  readonly property real tileHeight: {
    const size = logicalSize(focusedMonitor)
    return Math.round(tileWidth * Math.max(0.42, Math.min(0.75, size.height / size.width)))
  }
  readonly property string wallpaperUrl: wallpaper === "" ? ""
    : "file://" + wallpaper.split("/").map(encodeURIComponent).join("/")

  implicitWidth: pad * 2 + count * tileWidth + (count - 1) * gap
  implicitHeight: pad * 2 + tileHeight + footerGap + footer.height

  // Selects the workspace `delta` steps from the current one.
  function reset(delta) {
    const current = focusedMonitor?.activeWorkspace?.id ?? 0
    selected = current >= 1 && current <= count ? wrap(current + delta) : delta > 0 ? 1 : count
    cancelDrag()
    pendingMoves = {}
  }

  function step(delta) {
    selected = wrap(selected + delta)
  }

  function wrap(id) {
    return ((id - 1) % count + count) % count + 1
  }

  // In layout pixels, accounting for scale and rotation.
  function logicalSize(monitor) {
    if (!monitor) return { width: 1920, height: 1080 }
    const scale = monitor.scale || 1
    const width = monitor.width / scale
    const height = monitor.height / scale
    return (monitor.lastIpcObject?.transform ?? 0) % 2 === 1
      ? { width: height, height: width }
      : { width: width, height: height }
  }

  function workspaceOf(toplevel) {
    return pendingMoves[toplevel.address] ?? toplevel.workspace?.id ?? 0
  }

  // Bottom to top: tiled, floating, fullscreen, then by focus within each.
  function windowsOn(id) {
    const layer = toplevel => toplevel.lastIpcObject.fullscreen ? 2 : toplevel.lastIpcObject.floating ? 1 : 0
    return toplevels
      .filter(toplevel => workspaceOf(toplevel) === id
        && toplevel.lastIpcObject?.size && !toplevel.lastIpcObject.hidden)
      .sort((a, b) => layer(a) - layer(b)
        || (b.lastIpcObject.focusHistoryID ?? 0) - (a.lastIpcObject.focusHistoryID ?? 0))
  }

  function monitorOf(id) {
    return workspaces.find(workspace => workspace.id === id)?.monitor ?? focusedMonitor
  }

  function shownOn(id) {
    return monitors
      .filter(monitor => monitor.activeWorkspace?.id === id)
      .sort((a, b) => (b === focusedMonitor) - (a === focusedMonitor))
  }

  // Gaps count as the nearest tile, plus some slack above and below the row.
  function tileAt(point) {
    if (point.y < tileRow.y - 24 || point.y > tileRow.y + tileHeight + 24) return 0
    const index = Math.floor((point.x - tileRow.x + gap / 2) / (tileWidth + gap))
    return index >= 0 && index < count ? index + 1 : 0
  }

  function appName(toplevel) {
    const appClass = toplevel.lastIpcObject?.class ?? ""
    return Apps.forClass(appClass)?.name ?? appClass
  }

  // `grab` is the press point in the thumb's coordinates.
  function beginDrag(thumb, grab) {
    dragThumb = thumb
    grabOffset = grab
    dragPos = thumb.mapToItem(root, grab.x, grab.y)
    dragFrom = workspaceOf(thumb.toplevel)
  }

  function drop() {
    const toplevel = dragThumb?.toplevel
    const target = dropTarget
    cancelDrag()
    if (!toplevel || target === 0 || target === workspaceOf(toplevel)) return
    pendingMoves = Object.assign({}, pendingMoves, { [toplevel.address]: target })
    pendingExpiry.restart()
    windowMoved(toplevel.address, target)
  }

  function cancelDrag() {
    dragThumb = null
    dragFrom = 0
  }

  Timer {
    id: pendingExpiry
    interval: 1500
    onTriggered: root.pendingMoves = {}
  }

  // Follows workspace changes made while open, e.g. Super+number.
  Connections {
    target: root.focusedMonitor

    function onActiveWorkspaceChanged() {
      const id = root.focusedMonitor?.activeWorkspace?.id ?? 0
      if (id >= 1 && id <= root.count) root.selected = id
    }
  }

  Keys.onPressed: event => {
    switch (event.key) {
    case Qt.Key_Escape:
      if (root.dragThumb) root.cancelDrag()
      else root.cancelRequested()
      break
    case Qt.Key_Return:
    case Qt.Key_Enter:
      root.commitRequested()
      break
    case Qt.Key_Tab:
    case Qt.Key_Right:
      root.step(1)
      break
    case Qt.Key_Backtab:
    case Qt.Key_Left:
      root.step(-1)
      break
    default:
      if (event.key < Qt.Key_1 || event.key >= Qt.Key_1 + root.count) return
      root.selected = event.key - Qt.Key_0
      root.commitRequested()
    }
    event.accepted = true
  }

  Keys.onReleased: event => {
    if (event.key === Qt.Key_Alt) root.altReleased()
  }

  Row {
    id: tileRow
    x: root.pad
    y: root.pad
    spacing: root.gap

    Repeater {
      model: root.count

      WorkspaceTile {
        required property int index

        width: root.tileWidth
        height: root.tileHeight
        view: root
        workspaceId: index + 1
        windows: root.windowsOn(index + 1)
        monitor: root.monitorOf(index + 1)
        shownOn: root.shownOn(index + 1)
        selected: root.selected === index + 1
        dropTarget: root.dropTarget === index + 1 && root.dropTarget !== root.dragFrom
        onClicked: root.workspaceActivated(index + 1)
      }
    }
  }

  // The dragged window, drawn from its (meanwhile hidden) thumb.
  Item {
    id: ghost
    visible: !!root.dragThumb
    x: root.dragPos.x - root.grabOffset.x
    y: root.dragPos.y - root.grabOffset.y
    width: root.dragThumb?.width ?? 0
    height: root.dragThumb?.height ?? 0
    z: 1

    Rectangle {
      x: 3
      y: 5
      width: parent.width
      height: parent.height
      radius: 4
      color: "black"
      opacity: 0.35
    }

    ShaderEffectSource {
      anchors.fill: parent
      sourceItem: root.dragThumb
      hideSource: true
    }

    Rectangle {
      anchors.fill: parent
      radius: 3
      color: "transparent"
      border.width: 2
      border.color: Settings.textColorOnContainer
    }
  }

  Item {
    id: footer
    x: root.pad
    y: root.pad + root.tileHeight + root.footerGap
    width: root.width - root.pad * 2
    height: 22

    readonly property var dragged: root.dragThumb?.toplevel ?? null
    readonly property var selectedWindows: root.windowsOn(root.selected)

    Row {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - hints.width - 24
      spacing: 8

      EntryIcon {
        anchors.verticalCenter: parent.verticalCenter
        size: 18
        visible: !!footer.dragged
        icon: footer.dragged ? Apps.forClass(footer.dragged.lastIpcObject.class)?.icon ?? footer.dragged.lastIpcObject.class : ""
      }

      Looks.ClearText {
        anchors.verticalCenter: parent.verticalCenter
        text: footer.dragged ? "Moving " + root.appName(footer.dragged) : "Workspace " + root.selected
        color: Settings.textColorOnContainer
      }

      Looks.ClearText {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - x
        elide: Text.ElideRight
        opacity: 0.65
        color: Settings.textColorOnContainer
        text: footer.dragged
          ? "workspace " + root.dragFrom + " → " + (root.dropTarget > 0 && root.dropTarget !== root.dragFrom ? root.dropTarget : "…")
          : footer.selectedWindows.length === 0 ? "empty"
          : [...new Set(footer.selectedWindows.map(toplevel => root.appName(toplevel)))].join(", ")
      }
    }

    KeyHints {
      id: hints
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      keys: root.dragThumb ? [["release", root.dropTarget > 0 && root.dropTarget !== root.dragFrom ? "move here" : "put back"], ["Esc", "cancel"]]
        : root.sticky ? [["←→", "select"], ["↵", "switch"], ["drag", "move window"], ["Esc", "close"]]
        : [["Tab", "next"], ["Shift Tab", "back"], ["Alt", "release to switch"], ["drag", "move window"], ["Esc", "cancel"]]
    }
  }
}
