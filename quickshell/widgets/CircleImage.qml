import QtQuick
import QtQuick.Effects
import qs.common.looks as Looks
import qs

// Circular image, e.g. for a profile picture. Falls back to a placeholder
// glyph on the same circular background whenever no source is set or the
// image fails to load.
Item {
    id: root

    property alias source: image.source
    property real diameter: 32
    property string placeholderGlyph: "\u{f0009}"

    implicitWidth: diameter
    implicitHeight: diameter

    readonly property bool ready: image.status === Image.Ready

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: width / 2
        layer.enabled: true
        visible: false
    }

    Image {
        id: image
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        layer.enabled: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: image
        maskEnabled: true
        maskSource: mask
        visible: root.ready
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        visible: !root.ready
        color: Looks.Colors.md3.secondary_container

        Looks.ClearText {
            anchors.centerIn: parent
            text: root.placeholderGlyph
            color: Settings.textColorOnContainer
            font.pixelSize: root.diameter * 0.6
        }
    }
}
