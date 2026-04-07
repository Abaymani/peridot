import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.common.looks as Looks
import qs.services as Services

Rectangle {
  id: root
  height: Looks.Decorations.decor.elementHeight
  implicitWidth: mainLayout.implicitWidth + 20
  radius: Looks.Decorations.decor.radius
  gradient: Looks.Gradient { }

  RowLayout {
    id: mainLayout
    anchors.centerIn: parent
    height: parent.height
    spacing: 4

    // Icon Logic: Shows Ethernet icon if wired, otherwise WiFi icon
    Text {
      font.family: Looks.Fonts.family
      font.pixelSize: Looks.Fonts.size
      color: Looks.Colors.palette.neutral100 // Highlight the connection
      text: Services.Network.activeEthernet ? "󰈀" : "" 
    }

    // Name Logic: Shows "Wired" or the SSID of the WiFi
    Text {
      font.family: Looks.Fonts.family
      font.pixelSize: Looks.Fonts.size - 2
      color: Looks.Colors.palette.neutral100
      text: {
        if (Services.Network.activeEthernet) return "Wired";
        if (Services.Network.active) return Services.Network.active.ssid;
        return "Offline";
      }
    }

    Looks.Seperator {}

    // Download speed
    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Looks.Colors.palette.neutral100
      property var stats: Services.NetworkUsage.formatBytes(Services.NetworkUsage.downloadSpeed)
      text: `${stats.value.toFixed(1)} ` + stats.unit + "⬇" 
    }

    Looks.Seperator {}

    // Upload speed
    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Looks.Colors.palette.neutral100
      property var stats: Services.NetworkUsage.formatBytes(Services.NetworkUsage.uploadSpeed)
      text: `${stats.value.toFixed(1)} ` + stats.unit + "⬆"
    }
    
  }
}