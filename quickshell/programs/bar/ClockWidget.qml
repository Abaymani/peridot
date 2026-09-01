import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

Pill {
	id: clockPill
	implicitWidth: datetime.implicitWidth + 20

	RowLayout {
		id: datetime
		anchors.centerIn: parent
		height: parent.height

		Looks.ClearText {
			id: dateText
			text: Qt.formatDateTime(Time.time, "dddd, MM/dd")
			color: Settings.textColorOnContainer
		}

		Looks.Separator {
			color: Settings.textColorOnContainer
		}

		Looks.ClearText {
			id: clockText
			text: Qt.formatDateTime(Time.time, "hh:mm")
			color: Settings.textColorOnContainer
		}
	}
}
