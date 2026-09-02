import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services as Services
import qs.widgets
import qs

Pill {
  id: root
  implicitWidth: mainLayout.implicitWidth + 20

  RowLayout {
    id: mainLayout
    anchors.centerIn: parent
    height: parent.height
    spacing: 4

    Looks.ClearText {
      color: Settings.textColorOnContainer
      text: ""
    }
    Looks.ClearText {
      id: memoryText

      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer

      text: {
        let usage = Services.ResourceUsage.memoryUsed.toFixed(2).padStart(5, ' ');
        let total = Services.ResourceUsage.memoryTotal.toFixed(2);
        return `${usage}/${total} GiB`
      }
    }

    Looks.Separator {
      Layout.leftMargin: 2
      Layout.rightMargin: 3
      color: Settings.textColorOnContainer
    }

    Looks.ClearText {
      color: Settings.textColorOnContainer
      text: ""
    }

    Looks.ClearText {
      id: cpuText

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
    onClicked: {Quickshell.execDetached(["kitty", "htop"])}
  }
}
