import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    readonly property var gradientNames: ["PrimaryH3C", "PrimaryV2C", "PrimaryV3C", "WeakV2C", "WeakH2C"]

    Looks.ClearText {
        text: "Appearance"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Gradient backgrounds"
        description: "Use gradients instead of flat colors for pills and containers."

        Button {
            toggleButton: true
            checked: Settings.gradientBgEnabled
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Settings.gradientBgEnabled = !Settings.gradientBgEnabled
        }
    }

    SettingsRow {
        label: "Dark mode"
        description: "Used the next time matugen regenerates the theme from your wallpaper."

        Button {
            toggleButton: true
            checked: Settings.isDarkMode
            buttonText: checked ? "Dark" : "Light"
            fontSizeModifier: -1
            onClicked: Settings.isDarkMode = !Settings.isDarkMode
        }
    }

    SettingsRow {
        label: "Primary gradient"

        Dropdown {
            model: root.gradientNames
            currentIndex: root.gradientNames.indexOf(Settings.activeGradient)
            onActivated: (idx) => Settings.activeGradient = root.gradientNames[idx]
        }
    }

    SettingsRow {
        label: "Secondary gradient"

        Dropdown {
            model: root.gradientNames
            currentIndex: root.gradientNames.indexOf(Settings.activeSecondaryGradient)
            onActivated: (idx) => Settings.activeSecondaryGradient = root.gradientNames[idx]
        }
    }

    SettingsRow {
        label: "Background gradient"

        Dropdown {
            model: root.gradientNames
            currentIndex: root.gradientNames.indexOf(Settings.activebackgroundGradient)
            onActivated: (idx) => Settings.activebackgroundGradient = root.gradientNames[idx]
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Looks.ClearText {
            text: "Matugen source color"
            color: Settings.textColorOnContainer
        }
        Looks.ClearText {
            Layout.fillWidth: true
            text: "Which color from the wallpaper's extracted palette to build the theme from (0 = most dominant)."
            font.pixelSize: Looks.Fonts.size - 2
            opacity: 0.65
            color: Settings.textColorOnContainer
            wrapMode: Text.WordWrap
        }

        RadioBtnGroup {
            onPrimaryBg: true
            options: ["0", "1", "2", "3", "4"]
            selectedIndex: Settings.matugenSourceColorIndex
            onSelectionChanged: (idx) => Settings.matugenSourceColorIndex = idx
        }
    }

    Item { Layout.fillHeight: true }
}
