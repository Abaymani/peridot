import QtQuick
import colors.qml

QtObject {
	<* for name, value in colors *>
		readonly property color {{name}}: "{{value.default.hex}}"
	<* endfor *>
}
