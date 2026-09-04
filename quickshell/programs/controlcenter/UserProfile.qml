import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs.common.functions
import qs.widgets
import qs

// Profile card: picture with username/uptime to its right, anchored to the
// top so the rest of the card is free for future additions. Sized to span
// the combined height of the quick-tools button row and the dashboard box
// beside it (see ControlCenter.qml).
Rectangle {
  id: root

  property string uptime: "0"

  clip: true
  color: Settings.gradientBgEnabled
    ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
    : Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled
    ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject()
    : null
  radius: Looks.Decorations.decor.radius

  RowLayout {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 8
    spacing: 6

    CircleImage {
      Layout.alignment: Qt.AlignTop
      diameter: 32
      source: Settings.profilePicture !== "" ? "file://" + Settings.profilePicture : ""
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignTop
      spacing: 2

      Looks.ClearText {
        Layout.fillWidth: true
        text: Quickshell.env("USER")
        color: Settings.textColorOnContainer
        font.pixelSize: Looks.Fonts.size + 2
        font.weight: Font.Bold
        elide: Text.ElideRight
      }

      Looks.ClearText {
        Layout.fillWidth: true
        text: root.uptime
        font.pixelSize: Looks.Fonts.size - 1
        font.italic: true
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
      }
    }
  }

  Process {
    id: uptimeCmd
    command: ["bash", "-c", "uptime -r | awk '{sub(/[,.].*/, \"\", $2); s=$2; h=s/3600; if(h>99) printf \"%d days\\n\", h/24; else if(h>=1) printf \"%d hr\\n\", h; else printf \"%d min\\n\", s/60}'"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.uptime = this.text
    }
  }

  Timer {
    interval: 1000 * 60 * 10
    running: true
    repeat: true
    onTriggered: uptimeCmd.running = true
  }
}
