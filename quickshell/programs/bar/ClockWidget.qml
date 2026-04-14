import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services as Services
import qs

Rectangle {
	id: clockPill
	width: dateText.contentWidth + clockText.contentWidth + 32
	implicitHeight: Looks.Decorations.decor.elementHeight
	radius: Looks.Decorations.decor.radius
	
	color: Looks.Colors.md3.secondary_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
	

	RowLayout {
		id: datetime
		anchors.centerIn: parent
		height: parent.height

		Text {
			id: dateText
			font.family: Looks.Fonts.family
			font.pixelSize: Looks.Fonts.size 
			font.weight: Looks.Fonts.weight
			
			text: Qt.formatDateTime(Services.Time.time, "dddd, MM/dd")
			color: Settings.textColorOnContainer
		}

		Looks.Seperator {
			color: Settings.textColorOnContainer
		}

		Text {
			id: clockText
			
			font.family: Looks.Fonts.family
			font.pixelSize: Looks.Fonts.size 
			font.weight: Looks.Fonts.weight
			
			text: Qt.formatDateTime(Services.Time.time, "hh:mm")
			color: Settings.textColorOnContainer
		}
	}
}