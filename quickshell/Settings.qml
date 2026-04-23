pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
pragma ComponentBehavior: Bound
import qs.common.looks as Looks

Singleton {
    id: root
    property bool gradientBgEnabled: true

    property bool doNotDisturb: false

    property var toggleDND: GlobalShortcut {
        name: "toggleDND"
        onPressed: doNotDisturb = !doNotDisturb
    }

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
}
