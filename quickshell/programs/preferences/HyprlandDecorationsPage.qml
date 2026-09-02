import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.widgets
import qs.services as Services
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    readonly property var layouts: ["dwindle", "master"]

    Looks.ClearText {
        text: "Hyprland Decorations"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    Looks.ClearText {
        text: "GENERAL"
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.5
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Inner gap: " + Services.HyprlandDecorations.gapsIn + "px"

        NumberField {
            from: 0; to: 100; stepSize: 1
            value: Services.HyprlandDecorations.gapsIn
            onMoved: Services.HyprlandDecorations.gapsIn = value
        }
    }

    SettingsRow {
        label: "Outer gap: " + Services.HyprlandDecorations.gapsOut + "px"

        NumberField {
            from: 0; to: 100; stepSize: 1
            value: Services.HyprlandDecorations.gapsOut
            onMoved: Services.HyprlandDecorations.gapsOut = value
        }
    }

    SettingsRow {
        label: "Border size: " + Services.HyprlandDecorations.borderSize + "px"

        NumberField {
            from: 0; to: 100; stepSize: 1
            value: Services.HyprlandDecorations.borderSize
            onMoved: Services.HyprlandDecorations.borderSize = value
        }
    }

    SettingsRow {
        label: "Resize on border"
        description: "Resize windows by clicking and dragging on borders and gaps."

        Button {
            toggleButton: true
            checked: Services.HyprlandDecorations.resizeOnBorder
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Services.HyprlandDecorations.resizeOnBorder = !Services.HyprlandDecorations.resizeOnBorder
        }
    }

    SettingsRow {
        label: "Allow tearing"

        Button {
            toggleButton: true
            checked: Services.HyprlandDecorations.allowTearing
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Services.HyprlandDecorations.allowTearing = !Services.HyprlandDecorations.allowTearing
        }
    }

    SettingsRow {
        label: "Layout"

        Dropdown {
            model: root.layouts
            currentIndex: root.layouts.indexOf(Services.HyprlandDecorations.layout)
            onActivated: (idx) => Services.HyprlandDecorations.layout = root.layouts[idx]
        }
    }

    Looks.ClearText {
        text: "ROUNDING & OPACITY"
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.5
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Rounding: " + Services.HyprlandDecorations.rounding + "px"

        NumberField {
            from: 0; to: 100; stepSize: 1
            value: Services.HyprlandDecorations.rounding
            onMoved: Services.HyprlandDecorations.rounding = value
        }
    }

    SettingsRow {
        label: "Active window opacity: " + Services.HyprlandDecorations.activeOpacity.toFixed(2)

        NumberField {
            from: 0; to: 1; stepSize: 0.01; decimals: 2
            value: Services.HyprlandDecorations.activeOpacity
            onMoved: Services.HyprlandDecorations.activeOpacity = value
        }
    }

    SettingsRow {
        label: "Inactive window opacity: " + Services.HyprlandDecorations.inactiveOpacity.toFixed(2)

        NumberField {
            from: 0; to: 1; stepSize: 0.01; decimals: 2
            value: Services.HyprlandDecorations.inactiveOpacity
            onMoved: Services.HyprlandDecorations.inactiveOpacity = value
        }
    }

    Looks.ClearText {
        text: "EFFECTS"
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.5
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Blur"

        Button {
            toggleButton: true
            checked: Services.HyprlandDecorations.blurEnabled
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Services.HyprlandDecorations.blurEnabled = !Services.HyprlandDecorations.blurEnabled
        }
    }

    SettingsRow {
        label: "Shadows"

        Button {
            toggleButton: true
            checked: Services.HyprlandDecorations.shadowEnabled
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Services.HyprlandDecorations.shadowEnabled = !Services.HyprlandDecorations.shadowEnabled
        }
    }

    SettingsRow {
        label: "Animations"

        Button {
            toggleButton: true
            checked: Services.HyprlandDecorations.animationsEnabled
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Services.HyprlandDecorations.animationsEnabled = !Services.HyprlandDecorations.animationsEnabled
        }
    }

    Item { Layout.fillHeight: true }
}
