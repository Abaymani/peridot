import QtQuick
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs


Item {
  id: root

  required property var key
  // One key row's height and the gap between rows: a tall key (ISO Enter)
  // also covers the slot below it, left empty in the next row.
  property real rowHeight: height
  property real rowGap: 0

  readonly property bool isChar: key.kind === "char"
  readonly property bool shifted: isChar && Osk.shifted(key)
  readonly property bool altGr: isChar && Osk.altGrOn && key.altgr !== undefined
  readonly property bool latched: key.kind === "mod" || key.kind === "altgr" ? Osk.latched.includes(key.code)
    : key.kind === "shift" ? Osk.shiftState > 0
    : key.kind === "caps" ? Osk.shiftState === 2
    : false
  readonly property string mainLabel: !isChar ? key.label
    : altGr ? key.altgr
    : shifted ? (key.shift !== undefined ? key.shift : key.label.toUpperCase())
    : key.label
  readonly property string shiftLabel: isChar && key.shift !== undefined && !altGr ? (shifted ? key.label : key.shift) : ""
  readonly property string altGrLabel: isChar && key.altgr !== undefined && !altGr ? key.altgr : ""
  // Space shows the layout's name.
  readonly property bool isSpace: key.code === 57

  visible: key.kind !== "gap"

  Rectangle {
    id: face
    width: parent.width
    height: root.key.tall ? root.rowHeight * 2 + root.rowGap : parent.height
    radius: Math.min(Looks.Decorations.decor.radius + 4, root.rowHeight / 2)
    scale: mouseArea.pressed ? 0.94 : 1
    color: root.latched ? Looks.Colors.md3.surface_container
      : Settings.gradientBgEnabled
        ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, root.isChar ? 0.5 : 0.3)
        : root.isChar ? Looks.Colors.md3.surface_container : Looks.Colors.md3.surface_container_high
    gradient: root.latched && Settings.gradientBgEnabled
      ? Looks.Gradients.library[Settings.activeGradient].createObject()
      : null
    border.width: root.latched ? 1 : 0
    border.color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.35)

    Behavior on scale {
      NumberAnimation { duration: 60 }
    }

    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: Settings.textColorOnContainer
      opacity: mouseArea.pressed ? 0.18 : mouseArea.containsMouse ? 0.06 : 0
    }

    Looks.ClearText {
      anchors.centerIn: parent
      text: root.isSpace ? Osk.layout.name : root.mainLabel
      opacity: root.isSpace ? 0.4 : 1
      font.pixelSize: root.isChar ? Looks.Fonts.size + 5 : Looks.Fonts.size - 1
      color: Settings.textColorOnContainer
    }

    Looks.ClearText {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: 9
      anchors.topMargin: 5
      visible: root.shiftLabel !== ""
      text: root.shiftLabel
      font.pixelSize: Looks.Fonts.size - 2
      opacity: 0.55
      color: Settings.textColorOnContainer
    }

    Looks.ClearText {
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.rightMargin: 9
      anchors.bottomMargin: 5
      visible: root.altGrLabel !== ""
      text: root.altGrLabel
      font.pixelSize: Looks.Fonts.size - 2
      opacity: 0.55
      color: Settings.textColorOnContainer
    }

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onPressed: Osk.press(root.key)
      onReleased: Osk.release(root.key)
      onCanceled: Osk.release(root.key)
    }
  }
}
