pragma Singleton
import QtQuick
import Quickshell
import qs

// The widgets the bar can show, and where each goes: Settings.barLayout lists
// them per section, in order, as { left, center, right, hidden }.
Singleton {
  id: root

  readonly property var zones: ["left", "center", "right", "hidden"]
  readonly property var all: [
    { id: "updates", name: "Updates", glyph: "\u{f08c7}", description: "Pending package updates. Click to install them, right-click to check again." },
    { id: "workspaces", name: "Workspaces", glyph: "\u{f0570}", description: "Workspaces 1-6. Click one to switch to it." },
    { id: "activeWindow", name: "Active window", glyph: "\u{f05af}", description: "The focused window's title." },
    { id: "network", name: "Network", glyph: "\u{f1eb}", description: "Wi-Fi or wired connection, and VPN." },
    { id: "resources", name: "Resources", glyph: "\u{f2db}", description: "Memory and CPU use. Click for Mission Center." },
    { id: "audio", name: "Volume", glyph: "\u{f057e}", description: "Hover to change the volume, click for the mixer." },
    { id: "media", name: "Media", glyph: "\u{f075a}", description: "What's playing, with controls. Only shows while something plays." },
    { id: "tray", name: "Tray", glyph: "\u{f01d8}", description: "Icons that apps put in the system tray." },
    { id: "battery", name: "Battery", glyph: "\u{f0079}", description: "Charge level. Only shows on devices with a battery." },
    { id: "clock", name: "Clock", glyph: "\u{f0150}", description: "Date and time." },
    { id: "power", name: "Power", glyph: "\u{f0425}", description: "Opens the power menu. Right-click to lock." }
  ]
  // Where widgets go when the saved layout doesn't mention them.
  readonly property var defaults: ({
    left: ["updates", "workspaces", "activeWindow"],
    center: [],
    right: ["network", "resources", "audio", "media", "tray", "battery", "clock", "power"],
    hidden: []
  })

  readonly property var layout: normalize(Settings.barLayout)

  // `saved` with unknown widgets dropped, each widget listed once, and the
  // ones it doesn't mention (e.g. new ones) where `defaults` puts them.
  function normalize(saved) {
    const known = all.map(widget => widget.id)
    const seen = new Set()
    const result = {}
    for (const zone of zones) {
      result[zone] = []
      for (const id of Array.from(saved?.[zone] ?? [])) {
        if (!known.includes(id) || seen.has(id)) continue
        seen.add(id)
        result[zone].push(id)
      }
    }
    for (const zone of zones) {
      for (const id of defaults[zone]) {
        if (seen.has(id)) continue
        seen.add(id)
        result[zone].push(id)
      }
    }
    return result
  }

  function find(id) {
    return all.find(widget => widget.id === id)
  }

  function zoneOf(id) {
    return zones.find(zone => layout[zone].includes(id))
  }

  // Moves a widget to the end of `zone`.
  function moveTo(id, zone) {
    const next = copy()
    for (const other of zones) next[other] = next[other].filter(item => item !== id)
    next[zone].push(id)
    Settings.barLayout = next
  }

  // Moves a widget `delta` places along its section.
  function shift(id, delta) {
    const next = copy()
    const list = next[zoneOf(id)]
    const from = list.indexOf(id)
    const to = from + delta
    if (to < 0 || to >= list.length) return
    list.splice(from, 1)
    list.splice(to, 0, id)
    Settings.barLayout = next
  }

  // Back to `defaults`, including for widgets added later.
  function reset() {
    Settings.barLayout = {}
  }

  function copy() {
    return JSON.parse(JSON.stringify(layout))
  }
}
