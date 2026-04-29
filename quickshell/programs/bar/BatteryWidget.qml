import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs

Rectangle {
	id: batteryWidget
	width: batteryInfo.implicitWidth + 20
	implicitHeight: Looks.Decorations.decor.elementHeight
	radius: Looks.Decorations.decor.radius
    visible: BatteryService.hasBattery
	
	color: Looks.Colors.md3.secondary_container
	gradient: Settings.gradientBgEnabled 
		? Looks.Gradients.library[Settings.activeGradient].createObject()
		: null

    RowLayout {
		id: batteryInfo
		anchors.centerIn: parent
		height: parent.height

        Text {
			id: batteryPercentage
			font.family: Looks.Fonts.family
			font.pixelSize: Looks.Fonts.size 
			font.weight: Looks.Fonts.weight
			renderType: Text.NativeRendering

			text: BatteryService.percentage
			color: Settings.textColorOnContainer
		}

        Looks.Seperator {
			color: Settings.textColorOnContainer
		}

        Text {
			id: batteryIcon
			
			font.family: Looks.Fonts.family
			font.pixelSize: Looks.Fonts.size +4
			font.weight: Looks.Fonts.weight
			renderType: Text.NativeRendering
			
			text: BatteryService.icon
			color: Settings.textColorOnContainer
		}
    }
}