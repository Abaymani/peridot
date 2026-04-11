import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs

Scope {
	id: controlCenterRoot
	
	PanelWindow {
		id: root
		visible: GlobalStates.isControlCenterOpen
		screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

		WlrLayershell.layer: WlrLayer.Overlay
		exclusiveZone: 0

		anchors {
			top: true
			right: true
		}

		//TODO: move to settings
		implicitHeight: 600
		implicitWidth: 360

		margins{
			right: Looks.Decorations.decor.controlCenterMarginRight
			top: Looks.Decorations.decor.controlCenterMarginTop
		}

		color: "transparent"

		Rectangle{
			anchors.fill: parent
			gradient: Looks.Gradient {}
			radius: Looks.Decorations.decor.radius
		}
		
	}
}