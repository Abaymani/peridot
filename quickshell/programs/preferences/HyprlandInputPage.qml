import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common.looks as Looks
import qs.widgets
import qs.services as Services
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    Looks.ClearText {
        text: "Hyprland Input"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Keyboard layout"
        description: "XKB layout code, e.g. \"se\", \"us\", \"gb\"."

        TextField {
            Layout.preferredWidth: 100
            implicitHeight: Looks.Decorations.decor.elementHeight
            text: Services.HyprlandInput.kbLayout
            font.family: Looks.Fonts.family
            font.pixelSize: Looks.Fonts.size
            color: Settings.textColorOnContainer
            leftPadding: 10
            verticalAlignment: Text.AlignVCenter

            background: Rectangle {
                color: Looks.Colors.md3.surface_container
                radius: Looks.Decorations.decor.radius
                border.width: 1
                border.color: parent.activeFocus ? Looks.Colors.md3.primary : "#00000000"
            }

            onEditingFinished: Services.HyprlandInput.kbLayout = text
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Looks.ClearText {
            text: "Focus follows mouse: " + Services.HyprlandInput.followMouse
            color: Settings.textColorOnContainer
        }
        Looks.ClearText {
            Layout.fillWidth: true
            text: "0 = off, 1 = always follow, 2 = follow but don't switch on close, 3 = follow under mouse or keyboard."
            font.pixelSize: Looks.Fonts.size - 2
            opacity: 0.65
            color: Settings.textColorOnContainer
            wrapMode: Text.WordWrap
        }

        RadioBtnGroup {
            onPrimaryBg: true
            options: ["0", "1", "2", "3"]
            selectedIndex: Services.HyprlandInput.followMouse
            onSelectionChanged: (idx) => Services.HyprlandInput.followMouse = idx
        }
    }

    SettingsRow {
        label: "Mouse sensitivity: " + Services.HyprlandInput.sensitivity.toFixed(2)

        Slider {
            Layout.preferredWidth: 200
            from: -1; to: 1; stepSize: 0.05
            value: Services.HyprlandInput.sensitivity
            onMoved: Services.HyprlandInput.sensitivity = value
        }
    }

    SettingsRow {
        label: "Natural scroll"
        description: "Reverse touchpad scroll direction."

        Button {
            toggleButton: true
            checked: Services.HyprlandInput.naturalScroll
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Services.HyprlandInput.naturalScroll = !Services.HyprlandInput.naturalScroll
        }
    }

    Item { Layout.fillHeight: true }
}
