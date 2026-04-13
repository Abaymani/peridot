import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs
import qs.programs.controlcenter

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
		implicitWidth: Looks.Decorations.decor.controlCenterWidth

		margins{
			right: Looks.Decorations.decor.controlCenterMarginRight
			top: Looks.Decorations.decor.controlCenterMarginTop
		}

		color: "transparent"

		Rectangle{
			anchors.fill: parent
			gradient: Looks.Gradients.library[Settings.activebackgroundGradient].createObject() 
			radius: Looks.Decorations.decor.radius

			RowLayout{
				id: quicktools
				anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
				anchors.margins: 8
				spacing: 6

				Uptime {}
				Item { Layout.fillWidth: true }
				Screenshot {}
				Bluetooth {}
			}
		}
	}
}