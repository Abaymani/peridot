pragma Singleton
import QtQuick
import Quickshell
import qs.common.looks.gradients as G

Singleton {
    // A Map of names to Components
    readonly property var library: {
        "PrimaryH3C": _h3c,
        "PrimaryV2C": _v2c,
        "PrimaryV3C": _v3c,
    }

    // Define the actual components here
    readonly property Component _h3c: G.PrimaryH3C {}
    readonly property Component _v2c: G.PrimaryV2C {}
    readonly property Component _v3c: G.PrimaryV3C {}
}