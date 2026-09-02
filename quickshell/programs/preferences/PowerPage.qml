import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    readonly property var profiles: ["power-saver", "balanced", "performance"]
    readonly property var profileIcons: ["󱤅", "", ""]

    Looks.ClearText {
        text: "Power"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Automatic power profile"
        description: "Switch power profile automatically when (un)plugging the charger."

        Button {
            toggleButton: true
            checked: !Settings.userOverridePowerProfile
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Settings.userOverridePowerProfile = !Settings.userOverridePowerProfile
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        enabled: !Settings.userOverridePowerProfile
        opacity: !Settings.userOverridePowerProfile ? 1.0 : 0.5

        Looks.ClearText {
            text: "On battery"
            color: Settings.textColorOnContainer
        }

        RadioBtnGroup {
            onPrimaryBg: true
            options: root.profileIcons
            selectedIndex: root.profiles.indexOf(Settings.onBatteryPowerProfile)
            onSelectionChanged: (idx) => Settings.onBatteryPowerProfile = root.profiles[idx]
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        enabled: !Settings.userOverridePowerProfile
        opacity: !Settings.userOverridePowerProfile ? 1.0 : 0.5

        Looks.ClearText {
            text: "On charger"
            color: Settings.textColorOnContainer
        }

        RadioBtnGroup {
            onPrimaryBg: true
            options: root.profileIcons
            selectedIndex: root.profiles.indexOf(Settings.onChargerPowerProfile)
            onSelectionChanged: (idx) => Settings.onChargerPowerProfile = root.profiles[idx]
        }
    }

    Item { Layout.fillHeight: true }
}
