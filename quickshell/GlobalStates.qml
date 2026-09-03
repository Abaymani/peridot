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

    property bool isSettingsOpen: false

    // Single entry point for the settings button/keybind: open it fresh, pull
    // it to the active workspace if it's open elsewhere, or close it if it's
    // already open here. Reads Hyprland's live window list rather than
    // isSettingsOpen alone, since that's the only way to know which
    // workspace the window is actually on right now.
    //
    // The move's destination is resolved by Hyprland itself
    // (hl.get_active_workspace()) rather than interpolated from
    // Hyprland.focusedWorkspace here - that QML-side copy is updated
    // asynchronously over the IPC event stream and can briefly lag the real
    // compositor state right after a workspace switch, which would either
    // move the window to a stale workspace or make it look like it's
    // already on the active one and get closed instead of moved.
    function toggleSettings(): void {
        const win = Hyprland.toplevels.values.find(t => t.title === "Peridot Settings")

        if (!win) {
            root.isSettingsOpen = true
            return
        }

        const activeWorkspaceId = Hyprland.focusedWorkspace?.id
        if (win.workspace?.id === activeWorkspaceId) {
            root.isSettingsOpen = false
        } else {
            root.isSettingsOpen = true
            Hyprland.dispatch("hl.dsp.window.move({workspace = hl.get_active_workspace().id, window = 'title:^(Peridot Settings)$'})")
        }
    }

    property bool doNotDisturb: false
    property var toggleDND: GlobalShortcut {
        name: "toggleDND"
        onPressed: doNotDisturb = !doNotDisturb
    }
}
