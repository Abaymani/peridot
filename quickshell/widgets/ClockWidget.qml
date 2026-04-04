import QtQuick
import QtQuick.Layouts
import "../common/looks" as Looks
import "../services" as Services

Rectangle {
    id: clockPill
    width: dateText.contentWidth + clockText.contentWidth + 32
    implicitHeight: Looks.Decorations.decor.elementHeight
    radius: Looks.Decorations.decor.radius
    
    // Match the inactive workspace style or use a specific background
    gradient: Looks.Gradient {}
    

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