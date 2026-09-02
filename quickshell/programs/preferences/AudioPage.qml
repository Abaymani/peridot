import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    Looks.ClearText {
        text: "Audio"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Looks.ClearText {
            text: "Volume step: " + Settings.audioIncrement.toFixed(0) + "%"
            color: Settings.textColorOnContainer
        }
        Looks.ClearText {
            Layout.fillWidth: true
            text: "How much the volume changes per scroll or key press."
            font.pixelSize: Looks.Fonts.size - 2
            opacity: 0.65
            color: Settings.textColorOnContainer
            wrapMode: Text.WordWrap
        }

        NumberField {
            from: 1
            to: 20
            stepSize: 1
            value: Settings.audioIncrement
            onMoved: Settings.audioIncrement = value
        }
    }

    Item { Layout.fillHeight: true }
}
