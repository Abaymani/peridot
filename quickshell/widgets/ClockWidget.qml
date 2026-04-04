import QtQuick
import QtQuick.Layouts
import "../common/looks" as Looks
import "../services" as Services
import "../common/utils/functions.js" as Utils

Rectangle {
    id: clockPill
    
    // Adjust width/height based on your font size
    implicitWidth: dateText.contentWidth + clockText.contentWidth + 32
    implicitHeight: Looks.Decorations.decor.elementHeight
    radius: Looks.Decorations.decor.radius
    
    // Match the inactive workspace style or use a specific background
    gradient: gradient
            
    Gradient {
        id: gradient
        orientation: Gradient.Horizontal // Use Horizontal for a "pill" look
        GradientStop { position: -0.2; color: Looks.Colors.md3.primary }
        GradientStop { position: 0.2; color: '#14ffffff'}
        GradientStop { position: 1.0; color: Looks.Colors.md3.secondary } // Or any accent color
        
    }

    RowLayout {
        id: datetime
        anchors.centerIn: parent
        height: parent.height

        Text {
            id: dateText
            font.family: Looks.Fonts.family
            font.pixelSize: Looks.Fonts.size 
            font.weight: Looks.Fonts.weight
            
            text: Qt.formatDateTime(Services.Time.time, "yyyy-MM-dd")
            color: Looks.Colors.palette.neutral100
        }

        Looks.Seperator { }

        Text {
            id: clockText
            
            font.family: Looks.Fonts.family
            font.pixelSize: Looks.Fonts.size 
            font.weight: Looks.Fonts.weight
            
            text: Qt.formatDateTime(Services.Time.time, "hh:mm")
            color: Looks.Colors.palette.neutral100
        }
    }
    
}