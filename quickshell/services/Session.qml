pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Who's logged in, for how long, and the power menu's actions.
Singleton {
  id: root

  readonly property string user: Quickshell.env("USER")
  property string host: ""
  // e.g. "3 hr"; see refreshUptime().
  property string uptime: ""

  readonly property var actions: [
    { label: "Lock", glyph: "\u{f033e}", key: "L", hint: "Lock the screen",
      command: [Quickshell.env("HOME") + "/.config/peridot/scripts/lock.sh"] },
    { label: "Suspend", glyph: "\u{f04b2}", key: "U", hint: "Sleep, keeping everything in memory",
      command: ["systemctl", "suspend"] },
    { label: "Log out", glyph: "\u{f0343}", key: "E", hint: "End the Hyprland session",
      command: ["sh", "-c", "uwsm stop || hyprctl dispatch 'hl.dsp.exit()'"] },
    { label: "Reboot", glyph: "\u{f0709}", key: "R", hint: "Restart the computer",
      command: ["systemctl", "reboot"] },
    { label: "Shut down", glyph: "\u{f0425}", key: "S", hint: "Power off the computer",
      command: ["systemctl", "poweroff"] }
  ]

  function run(action) {
    Quickshell.execDetached(action.command)
  }

  function lock() {
    run(actions[0])
  }

  function refreshUptime() {
    uptimeProc.running = true
  }

  FileView {
    path: "/etc/hostname"
    onLoaded: root.host = text().trim()
  }

  Process {
    id: uptimeProc
    command: ["bash", "-c", "uptime -r | awk '{sub(/[,.].*/, \"\", $2); s=$2; h=s/3600; if(h>99) printf \"%d days\\n\", h/24; else if(h>=1) printf \"%d hr\\n\", h; else printf \"%d min\\n\", s/60}'"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.uptime = this.text.trim()
    }
  }

  Timer {
    interval: 1000 * 60 * 10
    running: true
    repeat: true
    onTriggered: root.refreshUptime()
  }
}
