import QtQuick
import QtQuick.Layouts
import "../common/looks" as Looks
import "../common/utils/functions.js" as Utils

Rectangle {
    id: clockPill
    
    // Adjust width/height based on your font size
    implicitWidth: clockText.contentWidth + 24 
    implicitHeight: 25
    radius: height / 2
    
    // Match the inactive workspace style or use a specific background
    gradient: gradient
            
    Gradient {
        id: gradient
        orientation: Gradient.Horizontal // Use Horizontal for a "pill" look
        GradientStop { position: -0.2; color: Looks.Colors.md3.primary }
        GradientStop { position: 0.1; color: '#74ffffff'}
        GradientStop { position: 1.0; color: Looks.Colors.md3.secondary } // Or any accent color
        
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        
        // Using the global font settings we discussed
        font.family: Looks.Fonts.family
        font.pixelSize: Looks.Fonts.size 
        font.weight: Looks.Fonts.weight
        
        text: Qt.formatDateTime(Time.time, "yyyy-MM-dd  hh:mm")
        color: Looks.Colors.palette.neutral100
    }
}