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
    spacing: 4

    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size
      color: Settings.textColorOnContainer
      text: ""
    }
    Text {
      id: memoryText

      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer
      renderType: Text.NativeRendering

      text: {
        let usage = Services.ResourceUsage.memoryUsed.toFixed(2).padStart(5, ' ');
        let total = Services.ResourceUsage.memoryTotal.toFixed(2);
        return `${usage}/${total} GiB`
      }
    }

    Looks.Seperator { 
      Layout.leftMargin: 2 
      Layout.rightMargin: 3
      color: Settings.textColorOnContainer
    }

    Text {
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size
      color: Settings.textColorOnContainer
      text: ""
    }

    Text {
      id: cpuText

      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size -2
      color: Settings.textColorOnContainer
      renderType: Text.NativeRendering

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