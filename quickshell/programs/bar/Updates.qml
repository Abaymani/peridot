import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services as Services
import qs.widgets
import qs

Pill {
	id: root

	// 2. Dynamic Width: Hug the content + padding
	implicitWidth: mainLayout.implicitWidth + 24
	clip: true


	// Smooth transition when the pill grows/shrinks or changes color
	Behavior on width { NumberAnimation { duration: 200 } }

	RowLayout {
		id: mainLayout
		anchors.centerIn: parent

		// --- Status Icon ---
		Looks.ClearText {
			id: iconText
			text: "󰣇" // Nerd Font: nf-md-update
			font.pixelSize: Looks.Fonts.size + 2
			color: Settings.textColorOnContainer
			transformOrigin: Item.Center
		}

		// --- Update Count ---
		Looks.ClearText {
			text: Services.UpdateService.isChecking ? "..." : Services.UpdateService.count
			font.pixelSize: Looks.Fonts.size -1
			color: Settings.textColorOnContainer
		}
	}

	// --- Interaction ---
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton

		// Update on click
		onClicked: (mouse) => {
			if (mouse.button === Qt.LeftButton) {Services.UpdateService.runUpdate()}
			else if (mouse.button === Qt.RightButton) {Services.UpdateService.checkUpdates()}
		}
	}
}
