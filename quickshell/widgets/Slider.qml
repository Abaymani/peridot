pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.common.looks

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
                root.value = Math.min(root.value + root.stepSize*2, 1)
                root.moved()
            } else {
                root.value = Math.max(root.value - root.stepSize*2, 0)
                root.moved()
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            implicitHeight: root.trackWidth
            radius: root.trackWidth / 2
            color: Colors.md3.secondary
        }

        Item {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: root.trackWidth
            width: parent.width * root.visualPosition
            clip: true

            Rectangle {
                width: background.width 
                height: root.trackWidth
                radius: root.trackWidth / 2
                color: Colors.md3.primary
            }
        }
    }

    handle: Circle {
        id: handle
        anchors.verticalCenter: parent.verticalCenter
        x: (diameter / 2) + root.visualPosition * (root.width - diameter) - (diameter / 2)
        diameter: 10
        color: Colors.md3.primary

        MouseArea {
            id: handleMouseArea
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
    }
}