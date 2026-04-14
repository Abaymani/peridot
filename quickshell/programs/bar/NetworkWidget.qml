import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.common.looks as Looks
import qs.services as Services

Rectangle {
  id: root
  height: Looks.Decorations.decor.elementHeight
  implicitWidth: mainLayout.implicitWidth + 20
  radius: Looks.Decorations.decor.radius
  
  color: Looks.Colors.md3.secondary_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null

  RowLayout {
    id: mainLayout
    anchors.centerIn: parent
    height: parent.height
    spacing: 6

  // Icon Logic: Shows Ethernet icon if wired, otherwise WiFi icon
    Text {
      font.family: Looks.Fonts.family
      font.pixelSize: Looks.Fonts.size
      color: Settings.textColorOnContainer
      text: Services.Network.activeEthernet ? "󰈀" : "" 
    }

    // Name Logic: Shows "Wired" or the SSID of the WiFi
    Text {
      font.family: Looks.Fonts.family
      font.pixelSize: Looks.Fonts.size - 2
      color: Settings.textColorOnContainer
      text: {
        if (Services.Network.activeEthernet) return "Wired";
        if (Services.Network.active) return Services.Network.active.ssid;
        return "Offline";
      }
    }

    Looks.Seperator {
      color: Settings.textColorOnContainer
    }

    // Download speed
    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer
      property var stats: Services.NetworkUsage.formatBytes(Services.NetworkUsage.downloadSpeed)
      text: `${stats.value.toFixed(1)} ` + stats.unit + "⬇" 
    }

    Looks.Seperator {
      color: Settings.textColorOnContainer
    }

    // Upload speed
    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer
      property var stats: Services.NetworkUsage.formatBytes(Services.NetworkUsage.uploadSpeed)
      text: `${stats.value.toFixed(1)} ` + stats.unit + "⬆"
    }
  }

  MouseArea{
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {Quickshell.execDetached(["hyprctl", "dispatch", "exec", "nm-connection-editor"])}
  }
}