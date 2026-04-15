import QtQuick
import QtQuick.Layouts
import qs.services
import qs
import qs.common.looks as Looks

Rectangle {
  id: root
  visible: MprisService.activePlayer !== null && MprisService.activeTrack?.title
  
  implicitHeight: Looks.Decorations.decor.elementHeight
  width: mainLayout.implicitWidth + (mainLayout.anchors.leftMargin * 2)

  radius: Looks.Decorations.decor.radius
  color: Looks.Colors.md3.secondary_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null


  RowLayout {
		id: mainLayout
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 10
    spacing: 8
    
    // --- Media Controls ---
    Row {
      spacing: 8
      Layout.alignment: Qt.AlignVCenter

      // Previous Button
      Text {
        text: "󰒮" // or "<<"
        font.pixelSize: Looks.Fonts.size * 1.2
        topPadding: 1
        color: MprisService.canGoPrevious ? Settings.textColorOnContainer : "#66ffffff"
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          enabled: MprisService.canGoPrevious
          onClicked: MprisService.previous()
        }
      }

      // Play/Pause Button
      Text {
        text: MprisService.isPlaying ? "󰏤" : "󰐊" // or "||" : ">"
        font.pixelSize: Looks.Fonts.size * 1.2
        topPadding: 1
        color: Settings.textColorOnContainer
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: MprisService.togglePlaying()
        }
      }

      // Next Button
      Text {
        text: "󰒭" // or ">>"
        font.pixelSize: Looks.Fonts.size * 1.2
        topPadding: 1
        color: MprisService.canGoNext ? Settings.textColorOnContainer : "#66ffffff"
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          enabled: MprisService.canGoNext
          onClicked: MprisService.next()
        }
      }
    }

    Looks.Seperator { }
    
    // --- Track Title (Scrolling Marquee) ---
		Item {
			id: textContainer
			width: 120
			height: parent.height
			clip: true // Hide the text when it scrolls outside this box

			Text {
				id: trackText
				text: (MprisService.activeTrack?.title ?? "Unknown") + 
        " - " + 
        "<b>" + (MprisService.activeTrack?.artist ?? "Unknown") + "</b>"
				
				anchors.verticalCenter: parent.verticalCenter
				font.family: Looks.Fonts.family
				font.pixelSize: Looks.Fonts.size - 2
				font.weight: Looks.Fonts.weight
				color: Settings.textColorOnContainer
        renderType: Text.NativeRendering

				// The Animation
				NumberAnimation on x {
					id: scrollAnim
					from: textContainer.width
					// Scroll to the end (negative width) plus the container width
					to: -trackText.contentWidth
					// Adjust speed based on text length (30ms per pixel is a good start)
					duration: Math.abs(to) * 35 
					loops: Animation.Infinite
					running: trackText.contentWidth > textContainer.width && MprisService.isPlaying
					paused: false
				}

				// Reset position if the track changes or becomes short enough to fit
				onTextChanged: {
					scrollAnim.stop();
					x = 0;
					if (trackText.contentWidth > textContainer.width && MprisService.isPlaying) {
							scrollAnim.start();
					}
				}
			}
		}

    Text {
      Layout.preferredWidth: 10
      Layout.alignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
      
      font.family: Looks.Fonts.family 
      font.pixelSize: Looks.Fonts.size + 2
      color: Settings.textColorOnContainer
      
      // This logic switches the icon based on the app name
      text: {
        let entry = (MprisService.activePlayer?.desktopEntry ?? "").toLowerCase();
        
        if (entry.includes("spotify")) return "󰓇"; // Spotify icon
        if (entry.includes("firefox")) return "󰈹"; // Firefox icon
        if (entry.includes("chromium") || entry.includes("chrome")) return "󰊯"; 
        if (entry.includes("vlc")) return "󰕼"; 
        if (entry.includes("mpv")) return "󰕼";
        
        return "󰎆"; // Default Music Note icon
      }
    }
  }
}