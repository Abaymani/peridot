import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../common/looks" as Looks
import "../common/utils/functions.js" as Utils

RowLayout {
    
    // Set a constant width for the entire module
    spacing: 6

    Repeater {
        model: 5

        Rectangle {
            id: wsRect
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            // 1. Create an animatable property for the "expansion factor"
            property real animWidth: isActive ? 60 : 25

            // 2. Animate that factor
            Behavior on animWidth {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
            Behavior on opacity { 
              NumberAnimation { duration: 200 } 
            }

            Layout.fillWidth: true
            Layout.preferredWidth: animWidth 
            implicitHeight: Looks.Decorations.decor.elementHeight
            
            radius: Looks.Decorations.decor.radius
            color: ws? Utils.setAlphaColor(Looks.Colors.md3.secondary, 0.4) : "#01000000"

            gradient: isActive ? activeGradient : null
            
            Gradient {
                id: activeGradient
                orientation: Gradient.Horizontal // Use Horizontal for a "pill" look
                GradientStop { position: -0.3; color: Looks.Colors.md3.primary }
                GradientStop { position: 0.3; color: '#74ffffff'}
                GradientStop { position: 1.0; color: Looks.Colors.md3.secondary } // Or any accent color
                
            }

            Text {
                id: wsText
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -1
                text: index + 1
                font.family: Looks.Fonts.family
                font.pixelSize: Looks.Fonts.size 
                font.weight: Looks.Fonts.weight
                color: isActive ? Looks.Colors.palette.neutral100 : Looks.Colors.palette.neutral100
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}