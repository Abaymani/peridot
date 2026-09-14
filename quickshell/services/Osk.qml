pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs
import "../common/KeyboardLayouts.js" as KeyboardLayouts

Singleton {
  id: root

  readonly property string device: "ydotoold-virtual-device"

  readonly property var layouts: KeyboardLayouts.layouts
  readonly property var layout: KeyboardLayouts.byId(Settings.oskLayout)
  readonly property var functionRow: KeyboardLayouts.functionRow

  // 0: off, 1: shift the next key, 2: caps lock
  property int shiftState: 0
  // Codes of the sticky modifiers that are on; they apply to the next key.
  property var latched: []
  readonly property bool altGrOn: layout.altGr !== undefined && latched.includes(layout.altGr)
  property bool ready: false

  // Modifier codes held down with each key that's down, by key code.
  property var heldWith: ({})
  property double lastShiftTap: 0

  function isLetter(key) {
    return key.kind === "char" && key.label.toUpperCase() !== key.label.toLowerCase()
  }

  function shifted(key) {
    return shiftState === 1 || (shiftState === 2 && isLetter(key))
  }

  // keys go down with the sticky modifiers (and Shift, if it's on) held.
  function press(key) {
    if (key.kind === "shift") {
      const now = Date.now()
      // A second tap within 300 ms turns on caps lock.
      shiftState = shiftState === 1 && now - lastShiftTap < 300 ? 2 : shiftState === 0 ? 1 : 0
      lastShiftTap = now
    } else if (key.kind === "caps") {
      shiftState = shiftState === 2 ? 0 : 2
    } else if (key.kind === "mod" || key.kind === "altgr") {
      latched = latched.includes(key.code) ? latched.filter(code => code !== key.code) : latched.concat([key.code])
    } else if (key.kind === "char" || key.kind === "key") {
      const held = latched.concat(shifted(key) ? [42] : [])
      heldWith = Object.assign({}, heldWith, { [key.code]: held })
      send(held.concat([key.code]).map(code => code + ":1"))
    }
  }

  // modifiers and a one-shot Shift are used up.
  function release(key) {
    const held = heldWith[key.code]
    if (held === undefined) return
    const rest = Object.assign({}, heldWith)
    delete rest[key.code]
    heldWith = rest
    send([key.code + ":0"].concat(held.slice().reverse().map(code => code + ":0")))
    latched = []
    if (shiftState === 1) shiftState = 0
  }

  // Lets go of everything, e.g. when the keyboard closes mid-press.
  function releaseAll() {
    const codes = []
    for (const code in heldWith) codes.push(Number(code), ...heldWith[code])
    heldWith = ({})
    latched = []
    shiftState = 0
    if (codes.length > 0) send(Array.from(new Set(codes)).map(code => code + ":0"))
  }

  function send(events) {
    Quickshell.execDetached(["ydotool", "key", "--key-delay", "0"].concat(events))
  }

  function cycleLayout() {
    Settings.oskLayout = layouts[(layouts.indexOf(layout) + 1) % layouts.length].id
    Settings.store.saveKey("oskLayout")
  }

  // Points ydotool's virtual keyboard at the layout in use.
  function applyLayout() {
    if (ready) Quickshell.execDetached(["hyprctl", "switchxkblayout", device, String(layouts.indexOf(layout))])
  }

  function refresh() {
    if (!status.running) status.running = true
  }

  Connections {
    target: Settings

    function onOskLayoutChanged() {
      root.latched = []
      root.applyLayout()
    }
  }

  Process {
    id: status
    command: ["systemctl", "--user", "is-active", "--quiet", "ydotool.service"]
    onExited: (exitCode, exitStatus) => {
      root.ready = exitCode === 0
      root.applyLayout()
    }
  }
}
