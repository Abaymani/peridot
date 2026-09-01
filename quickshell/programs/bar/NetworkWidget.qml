import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs
import qs.widgets
import qs.common.looks as Looks
import qs.services as Services

Pill {
  id: root
  implicitWidth: mainLayout.implicitWidth + 20

  RowLayout {
    id: mainLayout
    anchors.centerIn: parent
    height: parent.height
    spacing: 6

    // Icon Logic: Shows Ethernet icon if wired, otherwise WiFi icon
    Looks.ClearText {
      color: Settings.textColorOnContainer
      text: Services.Network.activeEthernet ? "󰈀" : ""
    }

    //Shows "Wired" or the SSID of the WiFi
    Looks.ClearText {
      font.pixelSize: Looks.Fonts.size - 2
      color: Settings.textColorOnContainer
      text: {
        if (Services.Network.activeEthernet) return "Wired";
        if (Services.Network.active) return Services.Network.active.ssid;
        return "Offline";
      }
    }

    Looks.Separator {
      color: Settings.textColorOnContainer
    }

    // Download speed
    Looks.ClearText {
      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer
      property var stats: Services.NetworkUsage.formatBytes(Services.NetworkUsage.downloadSpeed)
      text: `${stats.value.toFixed(1)} ` + stats.unit + "⬇"
    }

    Looks.Separator {
      color: Settings.textColorOnContainer
    }

    // Upload speed
    Looks.ClearText {
      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer
      property var stats: Services.NetworkUsage.formatBytes(Services.NetworkUsage.uploadSpeed)
      text: `${stats.value.toFixed(1)} ` + stats.unit + "⬆"
    }
  }

  MouseArea{
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: Hyprland.dispatch("hl.dsp.exec_cmd('nm-connection-editor')")
  }
}
