import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.looks as Looks
import qs.widgets
import qs

// Date and time, in the formats set in Preferences › Bar. Click for the
// calendar, which opens under the clock.
Pill {
	id: clockPill

	// Ticks every second only when a format shows seconds ('quoted' text aside).
	readonly property bool showsSeconds: /s/.test((Settings.barDateFormat + Settings.barTimeFormat).replace(/'[^']*'/g, ""))
	readonly property string screenName: QsWindow.window?.screen?.name ?? ""

	// The clock's centre on its screen; the bar sits barMarginLeft in.
	function centerX(): real {
		const rect = QsWindow.itemRect(clockPill)
		return Looks.Decorations.decor.barMarginLeft + rect.x + rect.width / 2
	}

	implicitWidth: datetime.implicitWidth + 20
	visible: Settings.barDateFormat !== "" || Settings.barTimeFormat !== ""

	// The calendar shortcut opens it under this clock, if it's on that screen.
	Connections {
		target: GlobalStates

		function onCalendarAnchorRequested(screenName: string): void {
			if (screenName === clockPill.screenName && clockPill.visible)
				GlobalStates.calendarAnchorX = clockPill.centerX()
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: GlobalStates.toggleCalendarAt(clockPill.screenName, clockPill.centerX())
	}

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
