import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.programs.bar
import qs.common.looks

Scope {
	id: root
	property string time

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: rootWindow
			required property var modelData
			screen: modelData

			anchors {
					top: true
					left: true
					right: true
			}

			margins {
					top: Decorations.decor.barMarginTop
					left: Decorations.decor.barMarginLeft
					right: Decorations.decor.barMarginRight
			}

			implicitHeight: Decorations.decor.barHeight
			color: "transparent"   

			Rectangle {
				anchors.fill: parent
				radius: Decorations.decor.radius
				color: "transparent"
				clip: true

				// Which widgets go where is set in Preferences › Bar.
				BarContent {
					anchors.fill: parent
				}
			}
		}
	}
}

