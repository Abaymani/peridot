import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs.services
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
		implicitHeight: 800
		implicitWidth: Looks.Decorations.decor.controlCenterWidth

		margins{
			right: Looks.Decorations.decor.controlCenterMarginRight
			top: Looks.Decorations.decor.controlCenterMarginTop
		}

		color: "transparent"

		Rectangle{
			anchors.fill: parent
			radius: Looks.Decorations.decor.radius

			color: Looks.Colors.md3.surface_container
			gradient: Settings.gradientBgEnabled 
				? Looks.Gradients.library[Settings.activebackgroundGradient].createObject() 
				: null
			
			ColumnLayout {
				anchors.fill: parent
				spacing: 12 // Space between rows
				anchors.margins: 8

				RowLayout {
					id: quicktools
					spacing: 6

					Uptime {}
					Item { Layout.fillWidth: true }
					ColorPicker {}
					Screenshot {}
					Bluetooth {}
					PeridotSettings {}
				}

				RowLayout {
					id: dashboard
					Layout.fillWidth: true
					
					Rectangle { 
						height: 80; Layout.fillWidth: true; 
						color: Looks.Colors.md3.secondary_container
						gradient: Settings.gradientBgEnabled 
    					? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject() 
							: null
						radius: Looks.Decorations.decor.radius
						Text {
							anchors.centerIn: parent
							font.family: Looks.Fonts.family
							font.pixelSize: Looks.Fonts.size
							font.weight: Looks.Fonts.weight
							color: Settings.textColorOnContainer
							text: "Placeholder: Dashboard\n->Resource-usage (detailed and with temps)\n->Battery\n->Brightness"
						}
					}
				}

				RowLayout {
					id: notifications
					Layout.fillWidth: true
					
					Rectangle { 
						height: 400; Layout.fillWidth: true; 
						color: Looks.Colors.md3.secondary_container
						gradient: Settings.gradientBgEnabled 
    					? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject() 
							: null
						radius: Looks.Decorations.decor.radius

						Text {
							anchors.centerIn: parent
							text: "No notifications..."
							
							font.family: Looks.Fonts.family
							font.pixelSize: Looks.Fonts.size + 4
							
							color: Settings.textColorOnContainer
							opacity: notificationList.count === 0 ? 0.5 : 0.0
						
							Behavior on opacity {
								NumberAnimation { 
									duration: 300 
									easing.type: Easing.InOutQuad 
								}
							}
						}

						ListView {
							id: notificationList
							anchors.fill: parent
							anchors.margins: 8
							spacing: 10
							clip: true

							model: Notifications.model
							
							delegate: NotificationItem {}

							add: Transition {
								NumberAnimation { 
									property: "opacity"
									from: 0
									to: 1
									duration: 300 
								}
							}

							remove: Transition {
								NumberAnimation { 
									property: "opacity"
									to: 0
									duration: 300 
								}
							}

							displaced: Transition {
								NumberAnimation { 
									properties: "y" 
									duration: 300 
									easing.type: Easing.OutQuad 
								}
							}
						}
					}
				}

				Item { Layout.fillHeight: true }
			}
		}
	}
}