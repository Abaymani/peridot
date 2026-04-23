import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs


Rectangle{
  color: Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
  implicitWidth: uptimeTextContainer.implicitWidth + 20
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight
  
  
  Row {
    id: uptimeTextContainer
    anchors.centerIn: parent
    spacing: 5

    Text {
      font.family: Looks.Fonts.family
      font.pixelSize: Looks.Fonts.size-1
      font.weight: Looks.Fonts.weight
      font.italic: true
      
      text: "Up:"
      color: Settings.textColorOnContainer
    }

    Text {
      id: uptimeText
      font.family: Looks.Fonts.family
      font.pixelSize: Looks.Fonts.size 
      font.weight: Looks.Fonts.weight
      
      text: "0"
      color: Settings.textColorOnContainer
    }
  }

  Process {
    id: uptimeCmd
    command: ["bash", "-c", "uptime -r | awk '{sub(/[,.].*/, \"\", $2); s=$2; h=s/3600; if(h>99) printf \"%d days\\n\", h/24; else if(h>=1) printf \"%d hr\\n\", h; else printf \"%d min\\n\", s/60}'"]
    running: true
		stdout: StdioCollector {
			onStreamFinished: {
				uptimeText.text = this.text
			}
		}
	}

	Timer {
		interval: 1000 * 60 * 10
		running: true
		repeat: true
		onTriggered: {
			uptimeCmd.running = true
		}
	}
}