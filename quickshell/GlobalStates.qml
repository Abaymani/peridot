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
    property bool isClipboardOpen: false

    property var toggleControlCenter: GlobalShortcut {
        name: "toggleControlCenter"
        onPressed: isControlCenterOpen = !isControlCenterOpen
    }

    property var toggleClipboard: GlobalShortcut {
        name: "toggleClipboard"
        onPressed: isClipboardOpen = !isClipboardOpen
    }
}