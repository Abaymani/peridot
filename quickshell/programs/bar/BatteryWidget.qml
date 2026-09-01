import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

Pill {
	id: batteryWidget
	implicitWidth: batteryInfo.implicitWidth + 20
    visible: BatteryService.available

    RowLayout {
		id: batteryInfo
		anchors.centerIn: parent
		height: parent.height

        Looks.ClearText {
			id: batteryPercentage
			font.pixelSize: Looks.Fonts.size -2

			text: Math.round(BatteryService.percentage * 100) + "%"
			color: Settings.textColorOnContainer
		}

        Looks.Separator {
			color: Settings.textColorOnContainer
		}

        Looks.ClearText {
			id: batteryIcon
			font.pixelSize: Looks.Fonts.size +4
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
