import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services as Services
import qs

Rectangle {
	id: root
	
	
	// 2. Dynamic Width: Hug the content + padding
	implicitWidth: mainLayout.implicitWidth + 24
	implicitHeight: Looks.Decorations.decor.elementHeight
	radius: Looks.Decorations.decor.radius
	clip: true

	
	gradient: Looks.Gradients.library[Settings.activeGradient].createObject()

	
	// Smooth transition when the pill grows/shrinks or changes color
	Behavior on width { NumberAnimation { duration: 200 } }

	RowLayout {
		id: mainLayout
		anchors.centerIn: parent

		// --- Status Icon ---
		Text {
			id: iconText
			text: "󰣇" // Nerd Font: nf-md-update
			font.family: Looks.Fonts.family
			font.pixelSize: Looks.Fonts.size + 2
			color: Looks.Colors.palette.neutral100
			transformOrigin: Item.Center
		}

		// --- Update Count ---
		Text {
			text: Services.UpdateService.isChecking ? "..." : Services.UpdateService.count
			font.family: Looks.Fonts.family
			font.pixelSize: Looks.Fonts.size -2
			font.weight: Looks.Fonts.weight
			color: Looks.Colors.palette.neutral100
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
