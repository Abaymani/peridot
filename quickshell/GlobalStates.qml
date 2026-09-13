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

    property bool isLauncherOpen: false
    property var toggleLauncher: GlobalShortcut {
        name: "toggleLauncher"
        onPressed: isLauncherOpen = !isLauncherOpen
    }

    property bool isSettingsOpen: false

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
