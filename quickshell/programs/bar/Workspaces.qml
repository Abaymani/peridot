import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs
import qs.common.functions

RowLayout {
	spacing: 6

	Repeater {
		model: 6

		Rectangle {
			id: wsRect
			property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
			property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

			// 1. Create an animatable property for the "expansion factor"
			property real animWidth: isActive ? 60 : 25

			// 2. Animate that factor
			Behavior on animWidth {
				NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
			}
			Behavior on opacity { 
				NumberAnimation { duration: 200 } 
			}

			Layout.fillWidth: true
			Layout.preferredWidth: animWidth 
			implicitHeight: Looks.Decorations.decor.elementHeight
			
			radius: Looks.Decorations.decor.radius
			color: isActive
				? Looks.Colors.md3.secondary_container
				: ws 
					? Settings.gradientBgEnabled ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.3) : Looks.Colors.md3.secondary_container
					: Settings.gradientBgEnabled ? "#01000000" : ColorUtils.setAlphaColor(Looks.Colors.md3.surface_bright, 0.3)

			gradient: Settings.gradientBgEnabled && isActive
				? Looks.Gradients.library[Settings.activeGradient].createObject()
				: null

			Text {
				id: wsText
				anchors.centerIn: parent
				anchors.horizontalCenterOffset: -1
				text: index + 1
				font.family: Looks.Fonts.family
				font.pixelSize: Looks.Fonts.size
				font.weight: Looks.Fonts.weight
				color: ws ? Settings.textColorOnContainer : Settings.textColorNotContainer
				renderType: Text.NativeRendering
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: Hyprland.dispatch("workspace " + (index + 1))
			}
		}
	}
}