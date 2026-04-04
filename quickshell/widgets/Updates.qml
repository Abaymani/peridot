import QtQuick
import QtQuick.Layouts
import "../common/looks" as Looks
import "../services" as Services
import "../widgets" as Widgets

Rectangle {
	id: root
	
	
	// 2. Dynamic Width: Hug the content + padding
	width: mainLayout.implicitWidth + 24
	implicitHeight: Looks.Decorations.decor.elementHeight
	radius: Looks.Decorations.decor.radius
	clip: true

	// 3. The Reusable Gradient: Uses the Enum to pick the "glow" color
	gradient: Looks.Gradient {
		midColor: {
			const current = Services.UpdateService.currentStatus;

			if (current === "red") return "#44ff4444";    // Transparent Red
			if (current === "yellow") return '#44fafa12'; // Transparent Yellow
			return '#0fffffff'
		}
	}

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

		// Update on click
		onClicked: Services.UpdateService.runUpdate()
	}
}
