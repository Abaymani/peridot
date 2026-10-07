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

    property bool isLauncherOpen: false
    // Asks the launcher for a mode (0 apps, 1 files, 2 clipboard). It opens
    // on that mode, switches to it, or closes if it's already showing it.
    signal launcherModeRequested(int mode)
    property var toggleLauncher: GlobalShortcut {
        name: "toggleLauncher"
        onPressed: {
            if (root.isLauncherOpen) root.isLauncherOpen = false
            else root.launcherModeRequested(0)
        }
    }
    // The clipboard is the launcher's third mode.
    property var toggleClipboard: GlobalShortcut {
        name: "toggleClipboard"
        onPressed: root.launcherModeRequested(2)
    }

    property bool isEmojiPickerOpen: false
    property var toggleEmojiPicker: GlobalShortcut {
        name: "toggleEmojiPicker"
        onPressed: root.isEmojiPickerOpen = !root.isEmojiPickerOpen
    }

    property bool isOskOpen: false
    property var toggleOsk: GlobalShortcut {
        name: "toggleOsk"
        onPressed: root.isOskOpen = !root.isOskOpen
    }
    
    property bool screenLocked: false
    property var lockIpc: IpcHandler {
        target: "lock"

        function locked(): void {
            root.screenLocked = true
        }

        function unlocked(): void {
            root.screenLocked = false
        }
    }
    property var lockCheck: Process {
        command: ["pidof", "hyprlock"]
        running: true
        onExited: (exitCode, exitStatus) => root.screenLocked = exitCode === 0
    }

    // The calendar opens under the clock that asked for it: on that clock's
    // screen, centred on calendarAnchorX (screen coordinates; -1 centres it
    // on the screen, e.g. when the clock is hidden).
    property bool isCalendarOpen: false
    property string calendarScreen: ""
    property real calendarAnchorX: -1
    // Asks the clock on `screenName` for calendarAnchorX.
    signal calendarAnchorRequested(string screenName)

    function toggleCalendarAt(screenName: string, anchorX: real): void {
        if (root.isCalendarOpen && root.calendarScreen === screenName) {
            root.isCalendarOpen = false
            return
        }
        root.calendarScreen = screenName
        root.calendarAnchorX = anchorX
        root.isCalendarOpen = true
    }

    property var toggleCalendar: GlobalShortcut {
        name: "toggleCalendar"
        onPressed: {
            if (root.isCalendarOpen) {
                root.isCalendarOpen = false
                return
            }
            const screenName = Hyprland.focusedMonitor?.name ?? ""
            root.calendarAnchorX = -1
            root.calendarAnchorRequested(screenName)
            root.toggleCalendarAt(screenName, root.calendarAnchorX)
        }
    }

    property bool isPowerMenuOpen: false
    property var togglePowerMenu: GlobalShortcut {
        name: "togglePowerMenu"
        onPressed: root.isPowerMenuOpen = !root.isPowerMenuOpen
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
