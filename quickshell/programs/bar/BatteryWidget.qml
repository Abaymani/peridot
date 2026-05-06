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
    visible: BatteryService.available
	
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
			font.pixelSize: Looks.Fonts.size -2 
			font.weight: Looks.Fonts.weight
			renderType: Text.NativeRendering

			text: Math.round(BatteryService.percentage * 100) + "%"
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
			
			text: getIcon()
			color: Settings.textColorOnContainer
		}
    }

	function getIcon() {
        if (BatteryService.isFull) return "󰁹";
        if (BatteryService.isCharging) return "󰂄";

		const percentage = BatteryService.percentage
        if (percentage < 0.15) return "󰂃";
        else if (percentage < 0.20) return "󰁻";
        else if (percentage < 0.30) return "󰁼";
        else if (percentage < 0.40) return "󰁽";
        else if (percentage < 0.50) return "󰁾";
        else if (percentage < 0.60) return "󰁿";
        else if (percentage < 0.70) return "󰂀";
        else if (percentage < 0.80) return "󰂁";
        else if (percentage < 0.90) return "󰂂";
        else return "󰁹";
    }
}