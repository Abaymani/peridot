import Quickshell
import QtQuick
import QtQuick.Layouts
import "../widgets" as Widgets
import "../common/looks" as Looks
import "../common/utils/functions.js" as Utils

Scope {
	id: root
	property string time

	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData
			screen: modelData

			anchors {
					top: true
					left: true
					right: true
			}

			margins {
					top: Looks.Decorations.decor.barMarginTop
					left: Looks.Decorations.decor.barMarginLeft
					right: Looks.Decorations.decor.barMarginRight
			}

			implicitHeight: Looks.Decorations.decor.barHeight
			color: "transparent"   

			Rectangle {
				anchors.fill: parent
				radius: Looks.Decorations.decor.radius
				color: "transparent"
				clip: true

				RowLayout {
					anchors.fill: parent
					spacing: 8

					Widgets.Updates { Layout.fillWidth: false }
					Widgets.Workspaces { Layout.fillWidth: false }
					Widgets.ActiveWindow { Layout.fillWidth: false}
					
					Item { Layout.fillWidth: true }
					Widgets.Mpris { Layout.fillWidth: false }
					Widgets.ClockWidget { }
				}
			}
		}
	}
}

