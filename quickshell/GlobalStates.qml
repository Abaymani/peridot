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
    property var toggleControlCenter: GlobalShortcut {
        name: "toggleControlCenter"
        onPressed: isControlCenterOpen = !isControlCenterOpen
    }

    property bool isClipboardOpen: false
    property var toggleClipboard: GlobalShortcut {
        name: "toggleClipboard"
        onPressed: isClipboardOpen = !isClipboardOpen
    }

    property bool doNotDisturb: false
    property var toggleDND: GlobalShortcut {
        name: "toggleDND"
        onPressed: doNotDisturb = !doNotDisturb
    }
}