import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.looks as Looks
import qs.widgets
import qs

// Date and time, in the formats set in Preferences › Bar.
Pill {
	id: clockPill

	// Ticks every second only when a format shows seconds ('quoted' text aside).
	readonly property bool showsSeconds: /s/.test((Settings.barDateFormat + Settings.barTimeFormat).replace(/'[^']*'/g, ""))

	implicitWidth: datetime.implicitWidth + 20
	visible: Settings.barDateFormat !== "" || Settings.barTimeFormat !== ""

	SystemClock {
		id: clock
		precision: clockPill.showsSeconds ? SystemClock.Seconds : SystemClock.Minutes
	}

	RowLayout {
		id: datetime
		anchors.centerIn: parent
		height: parent.height

		Looks.ClearText {
			id: dateText
			visible: Settings.barDateFormat !== ""
			text: Qt.formatDateTime(clock.date, Settings.barDateFormat)
			color: Settings.textColorOnContainer
		}

		Looks.Separator {
			visible: Settings.barDateFormat !== "" && Settings.barTimeFormat !== ""
			color: Settings.textColorOnContainer
		}

		Looks.ClearText {
			id: clockText
			visible: Settings.barTimeFormat !== ""
			text: Qt.formatDateTime(clock.date, Settings.barTimeFormat)
			color: Settings.textColorOnContainer
		}
	}
}
