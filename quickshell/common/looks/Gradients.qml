pragma Singleton
import QtQuick
import Quickshell
import qs.common.looks.gradients as G

Singleton {
    // A Map of names to Components
    readonly property var library: {
        "PrimaryH3C": _ph3c,
        "PrimaryV2C": _pv2c,
        "PrimaryV3C": _pv3c,
        "WeakV2C": _wv2c
    }

    // Define the actual components here
    readonly property Component _ph3c: G.PrimaryH3C {}
    readonly property Component _pv2c: G.PrimaryV2C {}
    readonly property Component _pv3c: G.PrimaryV3C {}
    readonly property Component _wv2c: G.WeakV2C {}
}