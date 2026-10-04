import QtQuick
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs.services as Services
import qs

// Memory and CPU usage as rings; hovering one shows its percentage. Opens
// Mission Center, like the bar's resources widget.
Row {
  spacing: 6

  component UsageRing: Item {
    id: ring

    property string glyph
    property real value

    implicitWidth: Looks.Decorations.decor.elementHeight
    implicitHeight: implicitWidth

    onValueChanged: canvas.requestPaint()

    // A Canvas rather than a Shape, so it's antialiased on any renderer.
    Canvas {
      id: canvas

      readonly property color strokeColor: Settings.textColorOnContainer

      anchors.fill: parent
      onStrokeColorChanged: requestPaint()

      onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.lineWidth = 3
        ctx.lineCap = "round"
        ctx.strokeStyle = strokeColor
        const radius = width / 2 - 2
        ctx.globalAlpha = 0.25
        ctx.beginPath()
        ctx.arc(width / 2, height / 2, radius, 0, 2 * Math.PI)
        ctx.stroke()
        if (ring.value <= 0) return
        ctx.globalAlpha = 1
        ctx.beginPath()
        ctx.arc(width / 2, height / 2, radius, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(1, ring.value))
        ctx.stroke()
      }
    }

    Looks.ClearText {
      readonly property string percent: Math.round(ring.value * 100)

      anchors.centerIn: parent
      text: mouseArea.containsMouse ? percent : ring.glyph
      font.pixelSize: !mouseArea.containsMouse ? Looks.Fonts.size - 1
        : percent.length > 2 ? Looks.Fonts.size - 3 : Looks.Fonts.size - 2
      color: Settings.textColorOnContainer
    }

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: Hyprland.dispatch("hl.dsp.exec_cmd('missioncenter')")
    }
  }

  UsageRing {
    glyph: "\u{efc5}"
    value: Services.ResourceUsage.memoryUsedPercentage
  }

  UsageRing {
    glyph: "\u{f2db}"
    value: Services.ResourceUsage.cpuUsage
  }
}
