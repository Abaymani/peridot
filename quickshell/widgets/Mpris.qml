import QtQuick
import QtQuick.Layouts
import "../services"
import "../common/looks" as Looks
import "../common/utils/functions.js" as Utils

Rectangle {
  id: root
  visible: MprisService.activePlayer !== null && MprisService.activeTrack?.title
  
  implicitHeight: Looks.Decorations.decor.elementHeight
  width: mainLayout.implicitWidth + (mainLayout.anchors.leftMargin * 2)

  radius: Looks.Decorations.decor.radius
  gradient: gradient
            
	Gradient {
		id: gradient
		orientation: Gradient.Horizontal // Use Horizontal for a "pill" look
		GradientStop { position: -0.2; color: Looks.Colors.md3.primary }
		GradientStop { position: .2; color: '#14ffffff'}
		GradientStop { position: 1.0; color: Looks.Colors.md3.secondary } // Or any accent color
	}
  clip: true

  RowLayout {
		id: mainLayout
    anchors.fill: parent
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    spacing: 10
    
    // --- Media Controls ---
    Row {
      spacing: 6
      Layout.alignment: Qt.AlignVCenter

      // Previous Button
      Text {
        text: "󰒮" // or "<<"
        font.pixelSize: Looks.Fonts.size * 1.2
        color: MprisService.canGoPrevious ? Looks.Colors.palette.neutral100 : "#66ffffff"
        
        MouseArea {
          anchors.fill: parent
          enabled: MprisService.canGoPrevious
          onClicked: MprisService.previous()
        }
      }

      // Play/Pause Button
      Text {
        text: MprisService.isPlaying ? "󰏤" : "󰐊" // or "||" : ">"
        font.pixelSize: Looks.Fonts.size * 1.2
        color: Looks.Colors.palette.neutral100
        
        MouseArea {
          anchors.fill: parent
          onClicked: MprisService.togglePlaying()
        }
      }

      // Next Button
      Text {
        text: "󰒭" // or ">>"
        font.pixelSize: Looks.Fonts.size * 1.2
        color: MprisService.canGoNext ? Looks.Colors.palette.neutral100 : "#66ffffff"
        
        MouseArea {
          anchors.fill: parent
          enabled: MprisService.canGoNext
          onClicked: MprisService.next()
        }
      }
    }

    // --- Vertical Divider ---
    Rectangle {
      width: 1
      height: parent.height * 0.4
      color: Looks.Colors.palette.neutral90
    }

    // --- Track Title (Scrolling Marquee) ---
		Item {
			id: textContainer
			width: 125
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
				color: Looks.Colors.palette.neutral100

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
  }
}