pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.common.looks as Looks

Slider {
    id: root

    property real trackWidth: 10
    property string tooltipContent: `${Math.round(value * 100)}`
    property bool scrollable: true
    stepSize: 0.02
    leftPadding: 0
    rightPadding: 0

    implicitHeight: handle.implicitHeight

    Behavior on value { // This makes the adjusted value (like volume) shift smoothly
        SmoothedAnimation {
            velocity: 0.7
        }
    }

    background: MouseArea {
        id: background
        anchors.fill: parent

        onWheel: (event) => {
            if (!root.scrollable) {
                event.accepted = false;
                return;
            }
            if (event.angleDelta.y > 0) {
                root.value = Math.min(root.value + root.stepSize, 1)
                root.moved()
            } else {
                root.value = Math.max(root.value - root.stepSize, 0)
                root.moved()
            }
        }

        Rectangle {
            id: trackHighlight
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            topLeftRadius: root.trackWidth / 2
            bottomLeftRadius: root.trackWidth / 2
            color: Looks.Colors.md3.primary
            implicitHeight: root.trackWidth
            width: background.width * root.visualPosition
        }

        Rectangle {
            id: trackTrough
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            topRightRadius: root.trackWidth / 2
            bottomRightRadius: root.trackWidth / 2
            color: Looks.Colors.md3.secondary
            implicitHeight: root.trackWidth
            width: background.width * (1 - root.visualPosition)
        }
    }

    handle: Circle {
        id: handle
        anchors.verticalCenter: parent.verticalCenter
        x: (diameter / 2) + root.visualPosition * (root.width - diameter) - (diameter / 2)
        diameter: 6
        color: Looks.Colors.md3.primary

        MouseArea {
            id: handleMouseArea
            anchors.fill: root
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        Circle {
            anchors.centerIn: parent
            diameter: root.pressed ? 10 : handleMouseArea.containsMouse ? 14 : 12
            color: Looks.Colors.md3.primary

            Behavior on diameter {
                animation: Looks.transition.enter.createObject(this)
            }
        }

        /*WToolTip {
            id: tooltip
            extraVisibleCondition: root.pressed
            text: root.tooltipContent
            font.pixelSize: Looks.Fonts.size
            verticalPadding: 3
            horizontalPadding: 8
        }*/
    }
}