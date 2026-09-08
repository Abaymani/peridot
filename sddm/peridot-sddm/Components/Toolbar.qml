import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property color colBackground: "#201f20"
    property real padding: 8
    property real cornerRadius: background.height / 2

    // Matches peridot shell's gradientBgEnabled toggle (see Settings.qml) -
    // when on, a gradient fully replaces the flat color fill, same as
    // Rectangle.gradient does throughout the rest of peridot.
    property bool gradientEnabled: false
    property color gradientStartColor: colBackground
    property color gradientEndColor: colBackground
    property alias spacing: toolbarLayout.spacing
    default property alias data: toolbarLayout.data

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.colBackground
        gradient: root.gradientEnabled ? bgGradient : null
        implicitHeight: 56
        implicitWidth: toolbarLayout.implicitWidth + root.padding * 2
        radius: root.cornerRadius

        Gradient {
            id: bgGradient
            orientation: Gradient.Horizontal
            GradientStop { position: 0.5; color: root.gradientStartColor }
            GradientStop { position: 1.0; color: root.gradientEndColor }
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
            radius: 9
            samples: 19
            color: Qt.rgba(0, 0, 0, 0.3)
            cached: true
        }

        RowLayout {
            id: toolbarLayout
            spacing: 4
            anchors {
                fill: parent
                margins: root.padding
            }
        }
    }
}
