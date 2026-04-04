import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    
    // Default properties that can be overridden when you use the widget
    property real verticalPadding: 0.6 // 60% of parent height
    property color separatorColor: Colors.palette.neutral90
    
    width: 1
    // We use implicitHeight so RowLayout knows how to size it
    implicitHeight: parent ? parent.height * verticalPadding : 14
    color: separatorColor
    
    // Ensure it stays centered in layouts
    Layout.alignment: Qt.AlignVCenter
    
    // Optional: Add a small rounded cap to the line
    radius: 1
}