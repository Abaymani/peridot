import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton
import Quickshell.Hyprland
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool isBarOpen: true
    property bool isControlCenterOpen: false

    property var toggleShortcut: GlobalShortcut {
        name: "toggleControlCenter"
        onPressed: isControlCenterOpen = !isControlCenterOpen
    }
}