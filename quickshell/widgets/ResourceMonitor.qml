import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../common/looks" as Looks
import "../services" as Services
import "../common/utils/functions.js" as Utils

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

    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size
      color: Looks.Colors.palette.neutral100
      text: ""
    }
    Text {
      id: memoryText

      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Looks.Colors.palette.neutral100

      text: {
        let usage = Services.ResourceUsage.memoryUsed.toFixed(2).padStart(5, ' ');
        let total = Services.ResourceUsage.memoryTotal.toFixed(2);
        return `${usage}/${total} GiB`
      }
    }

    Looks.Seperator { }

    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size
      color: Looks.Colors.palette.neutral100
      text: ""
    }

    Text {
      id: cpuText

      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Looks.Colors.palette.neutral100

      text: {
        let usage = (Services.ResourceUsage.cpuUsage * 100).toFixed(1);
        return `${usage.padEnd(4, ' ')}%`;
      }
    }
  }
}