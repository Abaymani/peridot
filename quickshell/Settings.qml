pragma Singleton
import QtQuick
import Quickshell
import qs.common.looks as Looks

Singleton {
    id: root
    property bool gradientBgEnabled: false

    property string activeGradient: "PrimaryH3C"
    property string activeSecondaryGradient: "PrimaryV2C"
    property string activebackgroundGradient: "WeakV2C"

    property color textColorOnContainer: gradientBgEnabled 
        ? Looks.Colors.palette.neutral100
        : Looks.Colors.md3.on_secondary_container
        
    property color textColorNotContainer: gradientBgEnabled
        ? Looks.Colors.palette.neutral100
        : Looks.Colors.md3.secondary
}
