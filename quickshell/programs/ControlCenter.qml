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
					
					// Your new content here
					Rectangle { 
						height: 400; Layout.fillWidth: true; 
						color: Looks.Colors.md3.secondary_container
						gradient: Settings.gradientBgEnabled 
    					? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject() 
							: null
						radius: Looks.Decorations.decor.radius

						ListView {
							anchors.fill: parent
							anchors.margins: 8
							spacing: 10
							clip: true
							
							// Feed the active notifications into the list
							model: Notifications.notificationServer.trackedNotifications
							
							delegate: Rectangle {
								width: ListView.view.width
								height: col.implicitHeight + 20
								color: Looks.Colors.md3.surface_container
								radius: Looks.Decorations.decor.radius
								
								Column {
									id: col
									anchors.top: parent.top
									anchors.left: parent.left
									anchors.right: parent.right
									anchors.margins: 10
									spacing: 5
									
									Text {
										text: modelData.summary
										font.family: Looks.Fonts.family
										font.pixelSize: Looks.Fonts.size + 2
										font.weight: Font.Bold
										color: Settings.textColorOnContainer
										elide: Text.ElideRight
										width: parent.width
									}
									
									Text {
										text: modelData.body
										font.family: Looks.Fonts.family
										font.pixelSize: Looks.Fonts.size
										font.weight: Looks.Fonts.weight
										color: Settings.textColorOnContainer
										wrapMode: Text.WordWrap
										width: parent.width
										visible: modelData.body !== ""
									}
								}
								
								// Dismiss notification when clicked
								MouseArea {
									anchors.fill: parent
									onClicked: {
										modelData.dismiss()
									}
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