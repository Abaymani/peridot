import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    Component.onCompleted: Osk.refresh()

    Looks.ClearText {
        text: "On-screen keyboard"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Layout"
        description: "What the keys type. Switching also switches ydotool's virtual keyboard to it, so the keys match their labels."

        RadioBtnGroup {
            onPrimaryBg: true
            options: Osk.layouts.map(layout => layout.name)
            selectedIndex: Osk.layouts.indexOf(Osk.layout)
            fontSizeModifier: -1
            onSelectionChanged: (idx) => Settings.oskLayout = Osk.layouts[idx].id
        }
    }

    SettingsRow {
        label: "Function row"
        description: "Esc, F1-F12, Print Screen and Delete above the number row."

        Button {
            toggleButton: true
            checked: Settings.oskFunctionRow
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Settings.oskFunctionRow = !Settings.oskFunctionRow
        }
    }

    SettingsRow {
        label: "Reserve space"
        description: "Windows make room for the keyboard instead of going under it (the pin on the keyboard)."

        Button {
            toggleButton: true
            checked: Settings.oskPinned
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Settings.oskPinned = !Settings.oskPinned
        }
    }

    SettingsRow {
        label: "Sending keys: " + (Osk.ready ? "ready" : "not set up")
        description: Osk.ready
            ? "ydotool's daemon is running."
            : "Keys are sent with ydotool, and its daemon isn't running. Install ydotool, then run: systemctl --user enable --now ydotool"

        Button {
            buttonText: "Check again"
            fontSizeModifier: -1
            onClicked: Osk.refresh()
        }
    }

    Item { Layout.fillHeight: true }
}
