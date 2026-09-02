pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
pragma ComponentBehavior: Bound
import qs.common.looks as Looks
import qs.services

Singleton {
    id: root

    //POWER PROFILES
    property alias userOverridePowerProfile: jsonAdapter.userOverridePowerProfile
    property alias onBatteryPowerProfile: jsonAdapter.onBatteryPowerProfile
    property alias onChargerPowerProfile: jsonAdapter.onChargerPowerProfile

    //DIRECTORIES (TODO: Move to separate file)
    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)
    readonly property string iconPath: StandardPaths.standardLocations(StandardPaths.HomeLocation) + "/.local/share/icons/YAMIS"

    //LOOKS
    property alias gradientBgEnabled: jsonAdapter.gradientBgEnabled
    property alias activeGradient: jsonAdapter.activeGradient
    property alias activeSecondaryGradient: jsonAdapter.activeSecondaryGradient
    property alias activebackgroundGradient: jsonAdapter.activebackgroundGradient

    property color textColorOnContainer: gradientBgEnabled
        ? Looks.Colors.palette.neutral100
        : Looks.Colors.md3.on_secondary_container

    property color textColorNotContainer: gradientBgEnabled
        ? Looks.Colors.palette.neutral100
        : Looks.Colors.palette.neutral100

    property color textColorOnLight: gradientBgEnabled
        ? Looks.Colors.palette.neutral100
        : Looks.Colors.palette.neutral20

    //MATUGEN
    property alias isDarkMode: jsonAdapter.isDarkMode
    property alias matugenSourceColorIndex: jsonAdapter.matugenSourceColorIndex //pick a source color based on the index provided (0 - 4) 0 = most dominant, 1 = 2nd most dominant, etc
    property string currentWallpaper: ""
    Component.onCompleted: {MatugenService.init()} //TODO: move somewhere else!

    //AUDIO
    property alias audioIncrement: jsonAdapter.audioIncrement

    // --- Persistence ---
    // Properties above are the live/draft state - every change (e.g. from a
    // future settings UI) applies immediately, same as today. Nothing is
    // written to disk until save() is called; revert() discards in-memory
    // changes and reloads the last-saved state (asynchronously - properties
    // update reactively once the reload completes, not on the same tick).
    function save(): void {
        settingsFile.writeAdapter();
    }

    function revert(): void {
        settingsFile.reload();
    }

    FileView {
        id: settingsFile
        path: Quickshell.env("HOME") + "/.config/peridot/settings/settings.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonAdapter

            property bool userOverridePowerProfile: true
            property string onBatteryPowerProfile: "power-saver"
            property string onChargerPowerProfile: "performance"

            property bool gradientBgEnabled: true
            property string activeGradient: "PrimaryH3C"
            property string activeSecondaryGradient: "PrimaryV2C"
            property string activebackgroundGradient: "WeakH2C"

            property bool isDarkMode: true
            property int matugenSourceColorIndex: 0

            property real audioIncrement: 5
        }
    }
}
