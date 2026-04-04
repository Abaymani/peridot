import QtQuick
import QtQuick.Layouts
import "../common/looks" as Looks
import "../common/utils/functions.js" as Utils

Rectangle {
    id: clockPill
    
    // Adjust width/height based on your font size
    implicitWidth: dateText.contentWidth + sep.contentWidth + clockText.contentWidth + 40 
    implicitHeight: Looks.Decorations.decor.elementHeight
    radius: Looks.Decorations.decor.radius
    
    // Match the inactive workspace style or use a specific background
    gradient: gradient
            
    Gradient {
        id: gradient
        orientation: Gradient.Horizontal // Use Horizontal for a "pill" look
        GradientStop { position: -0.2; color: Looks.Colors.md3.primary }
        GradientStop { position: 0.1; color: '#74ffffff'}
        GradientStop { position: 1.0; color: Looks.Colors.md3.secondary } // Or any accent color
        
    }

    RowLayout {
        id: datetime
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: dateText
            
            // Using the global font settings we discussed
            font.family: Looks.Fonts.family
            font.pixelSize: Looks.Fonts.size 
            font.weight: Looks.Fonts.weight
            
            text: Qt.formatDateTime(Time.time, "yyyy-MM-dd")
            color: Looks.Colors.palette.neutral100
        }

        Text {
            id: sep
            

            font.family: Looks.Fonts.family
            font.pixelSize: Looks.Fonts.size 
            font.weight: Looks.Fonts.weight
            
            text: "|"
            color: Looks.Colors.palette.neutral90
        }

        Text {
            id: clockText
            

            font.family: Looks.Fonts.family
            font.pixelSize: Looks.Fonts.size 
            font.weight: Looks.Fonts.weight
            
            text: Qt.formatDateTime(Time.time, "hh:mm")
            color: Looks.Colors.palette.neutral100
        }
    }
    
}