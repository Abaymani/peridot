pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property bool gradientBgEnabled: true
    property string activeGradient: "PrimaryH3C"
    property string activeSecondaryGradient: "PrimaryV2C"
    property string activebackgroundGradient: "WeakV2C"
}
