pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Hyprland
pragma ComponentBehavior: Bound
import qs.common.looks as Looks
import qs.services

Singleton {
    id: root

    //POWER PROFILES
    property bool userOverridePowerProfile: false
    property string onBatteryPowerProfile: "power-saver"
    property string onChargerPowerProfile: "performance" 

    //DIRECTORIES (TODO: Move to separate file)
    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)
    readonly property string iconPath: StandardPaths.standardLocations(StandardPaths.HomeLocation) + "/.local/share/icons/YAMIS"

    //LOOKS
    property bool gradientBgEnabled: false
    property string activeGradient: "PrimaryH3C"
    property string activeSecondaryGradient: "PrimaryV2C"
    property string activebackgroundGradient: "WeakV2C"

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
    property bool isDarkMode: true
    property int matugenSourceColorIndex: 0 //pick a source color based on the index provided (0 - 4) 0 = most dominant, 1 = 2nd most dominant, etc
    property string currentWallpaper: ""
    Component.onCompleted: {MatugenService.init()} //TODO: move somewhere else!
}
