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

			color: Looks.Colors.md3.secondary_container
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
					OpenClipboard {}
					Screenshot {}
					Bluetooth {}
					PeridotSettings {}
				}

				RowLayout {
					id: dashboard
					Layout.fillWidth: true
					
					Rectangle { 
						height: 80; Layout.fillWidth: true; 
						color: Looks.Colors.md3.surface_container
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
						color: Looks.Colors.md3.surface_container
						gradient: Settings.gradientBgEnabled 
    					? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject() 
							: null
						radius: Looks.Decorations.decor.radius

						ColumnLayout{
							anchors.fill: parent
              anchors.margins: 8

							RowLayout{
								Layout.fillWidth: true
								spacing: 8
								
								Rectangle{
									color: Looks.Colors.md3.secondary_container
									gradient: Settings.gradientBgEnabled 
										? Looks.Gradients.library[Settings.activeGradient].createObject()
										: null
									implicitWidth: Settings.doNotDisturb? dndBtn.implicitWidth + 38 : dndBtn.implicitWidth + 40
									radius: Looks.Decorations.decor.radius
									height: Looks.Decorations.decor.elementHeight

									Text {
										id: dndBtn
										anchors.centerIn: parent
										font.family: Looks.Fonts.family
										font.pixelSize: Looks.Fonts.size+5
										font.weight: Looks.Fonts.weight
										text: Settings.doNotDisturb? "󰂛" : "󰂚"
										color: Settings.textColorOnContainer
									}

									MouseArea {
										anchors.fill: parent
										cursorShape: Qt.PointingHandCursor
										hoverEnabled: true

										onClicked: Settings.doNotDisturb  = !Settings.doNotDisturb 
									}
								}

								Text {
									Layout.fillWidth: true
									horizontalAlignment: Text.AlignHCenter
									font.family: Looks.Fonts.family
									font.pixelSize: Looks.Fonts.size
									font.weight: Looks.Fonts.weight
									text: `${Notifications.model.count} notification${Notifications.model.count === 1 ? "" : "s"}`
									color: Settings.textColorOnContainer
								}

								Rectangle{
									color: Looks.Colors.md3.secondary_container
									gradient: Settings.gradientBgEnabled 
										? Looks.Gradients.library[Settings.activeGradient].createObject()
										: null
									implicitWidth: wipeNotifications.implicitWidth + 40
									radius: Looks.Decorations.decor.radius
									height: Looks.Decorations.decor.elementHeight

									Text {
										id: wipeNotifications
										anchors.centerIn: parent
										anchors.horizontalCenterOffset: 2
										font.family: Looks.Fonts.family
										font.pixelSize: Looks.Fonts.size+5
										font.weight: Looks.Fonts.weight
										text: "󰛌"
										color: Settings.textColorOnContainer
									}

									MouseArea {
										anchors.fill: parent
										cursorShape: Qt.PointingHandCursor
										hoverEnabled: true

										onClicked: Notifications.clearNotifications()
									}
								}
							}

							Item {
								Layout.fillWidth: true
								Layout.fillHeight: true

								ListView {
									id: notificationList
									anchors.fill: parent
									spacing: 6
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
					}
				}
				Item { Layout.fillHeight: true }
			}
		}
	}
}