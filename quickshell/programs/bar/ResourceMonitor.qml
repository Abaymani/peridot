import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs.services as Services
import qs.widgets
import qs

Pill {
  id: root
  readonly property bool showsMemory: Settings.barMemoryDisplay !== "hidden"

  implicitWidth: mainLayout.implicitWidth + 20
  visible: showsMemory || Settings.barCpuUsage

  RowLayout {
    id: mainLayout
    anchors.centerIn: parent
    height: parent.height
    spacing: 4

    Looks.ClearText {
      visible: root.showsMemory
      color: Settings.textColorOnContainer
      text: ""
    }
    Looks.ClearText {
      id: memoryText
      visible: root.showsMemory

      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer

      text: {
        if (Settings.barMemoryDisplay === "percent")
          return (Services.ResourceUsage.memoryUsedPercentage * 100).toFixed(1).padStart(4, ' ') + "%";
        let usage = Services.ResourceUsage.memoryUsed.toFixed(2).padStart(5, ' ');
        let total = Services.ResourceUsage.memoryTotal.toFixed(2);
        return `${usage}/${total} GiB`
      }
    }

    Looks.Separator {
      visible: root.showsMemory && Settings.barCpuUsage
      Layout.leftMargin: 2
      Layout.rightMargin: 3
      color: Settings.textColorOnContainer
    }

    Looks.ClearText {
      visible: Settings.barCpuUsage
      color: Settings.textColorOnContainer
      text: ""
    }

    Looks.ClearText {
      id: cpuText
      visible: Settings.barCpuUsage

      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer

      text: {
        let usage = (Services.ResourceUsage.cpuUsage * 100).toFixed(1);
        return `${usage.padEnd(4, ' ')}%`;
      }
    }
  }

  MouseArea{
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: Hyprland.dispatch("hl.dsp.exec_cmd('missioncenter')")
  }
}
