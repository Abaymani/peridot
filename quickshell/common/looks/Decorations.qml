pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	property alias decor: jsonAdapter.decor

	FileView {
		path: Quickshell.env("HOME") + "/.config/quickshell/common/looks/decor.json"
		watchChanges: true
		onFileChanged: reload()

		JsonAdapter {
			id: jsonAdapter
			readonly property Decorations decor: Decorations {}
		}
	}

	//defaults
	component Decorations: JsonObject {
		property int radius: 10
		property int barHeight: 25
		property int barMarginTop: 0
		property int barMarginLeft: 0
		property int barMarginRight: 0
		property int elementHeight: 25
		property int controlCenterMarginRight: 0
		property int controlCenterMarginTop: 0
		property int controlCenterWidth: 360
	}
}