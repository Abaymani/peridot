pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs

// The wallpaper folder and the backend that shows it. Lists the folder through
// peridot/scripts/wallpaper-index.sh, which also keeps the thumbnail cache.
//
// The daemon restores the last wallpaper by itself.
Singleton {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string folder: expandHome(Settings.wallpaperFolder)
  readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || home + "/.cache") + "/peridot/wallpapers"
  readonly property string current: Settings.currentWallpaper

  // Every image as { path, name, format, mtime, bytes, width, height, thumbnail },
  // in Settings.wallpaperOrder.
  readonly property var wallpapers: sorted(entries, Settings.wallpaperOrder)
  readonly property int currentIndex: wallpapers.findIndex(entry => entry.path === current)
  readonly property var currentEntry: currentIndex >= 0 ? wallpapers[currentIndex] : null

  property var entries: []
  property bool scanning: false
  // The listing in progress, for "making thumbnails" progress.
  property int scanTotal: 0
  property int scanDone: 0

  readonly property var supportedBackends: ["awww", "swww"]
  property var installedBackends: []
  // The setting, or another installed backend if that one isn't installed.
  readonly property string backend: installedBackends.includes(Settings.wallpaperBackend)
    ? Settings.wallpaperBackend
    : installedBackends[0] ?? ""

  property bool initialized: false

  Component.onCompleted: {
    initialized = true
    backendCheck.running = true
    rescan()
  }

  function expandHome(path: string): string {
    return path === "~" || path.startsWith("~/") ? home + path.slice(1) : path
  }

  function tildePath(path: string): string {
    return path === home || path.startsWith(home + "/") ? "~" + path.slice(home.length) : path
  }

  function fileUrl(path: string): string {
    return path === "" ? "" : "file://" + path.split("/").map(encodeURIComponent).join("/")
  }

  // "3840 × 2160 · PNG · 15.6 MB"
  function describe(entry): string {
    if (!entry) return ""
    const parts = []
    if (entry.width > 0) parts.push(entry.width + " × " + entry.height)
    parts.push(entry.format)
    parts.push(entry.bytes >= 1024 * 1024
      ? (entry.bytes / 1024 / 1024).toFixed(1) + " MB"
      : Math.max(1, Math.round(entry.bytes / 1024)) + " KB")
    return parts.join(" · ")
  }

  function sorted(list, order: string): var {
    const result = list.slice()
    if (order === "newest")
      result.sort((a, b) => b.mtime - a.mtime || a.name.localeCompare(b.name))
    else
      result.sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()))
    return result
  }

  function rescan(): void {
    if (scanProcess.running) {
      scanProcess.again = true
      return
    }
    scanProcess.found = []
    root.scanDone = 0
    root.scanTotal = 0
    root.scanning = true
    scanProcess.command = [
      "bash", root.home + "/.config/peridot/scripts/wallpaper-index.sh",
      root.folder, Settings.wallpaperSubfolders ? "1" : "0", root.cacheDir
    ]
    scanProcess.running = true
  }

  function apply(path: string): void {
    if (path === "") return
    if (root.backend === "") {
      notify("No wallpaper backend", "Install awww or swww to set wallpapers.")
      return
    }
    if (applyProcess.running) {
      // Only the newest request matters.
      applyProcess.queued = path
      return
    }
    const resize = { fill: "crop", fit: "fit", center: "no", stretch: "stretch" }
    const args = [
      "img", path,
      "--resize", resize[Settings.wallpaperScaling] ?? "crop",
      "--fill-color", Settings.wallpaperFillColor.replace("#", ""),
      "--transition-type", Settings.wallpaperTransition,
      "--transition-duration", String(Settings.wallpaperTransitionDuration),
      "--transition-fps", String(Settings.wallpaperTransitionFps),
      "--transition-angle", String(Settings.wallpaperTransitionAngle)
    ]
    if (Settings.wallpaperMonitors === "focused" && Hyprland.focusedMonitor)
      args.push("--outputs", Hyprland.focusedMonitor.name)
    applyProcess.path = path
    applyProcess.command = ["sh", "-c", root.withDaemon + ' exec "$b" "$@"', "sh", root.backend].concat(args)
    applyProcess.running = true
  }

  // A wallpaper other than the current one, picked at random.
  function applyRandom(): void {
    const others = root.wallpapers.filter(entry => entry.path !== root.current)
    if (others.length > 0) apply(others[Math.floor(Math.random() * others.length)].path)
  }

  function notify(summary: string, body: string): void {
    Quickshell.execDetached(["notify-send", summary, body, "-a", "Shell", "--hint=int:transient:1"])
  }

  // Shell snippet: starts "$b-daemon" unless it's already answering, and waits
  // up to five seconds for it. Expects the backend in $1.
  readonly property string withDaemon: 'b=$1; shift; '
    + 'if ! "$b" query >/dev/null 2>&1; then '
    + 'setsid -f "$b-daemon" >/dev/null 2>&1; '
    + 'i=0; while [ $i -lt 25 ] && ! "$b" query >/dev/null 2>&1; do sleep 0.2; i=$((i + 1)); done; '
    + 'fi;'

  Process {
    id: backendCheck
    command: ["sh", "-c", 'for b in "$@"; do command -v "$b" >/dev/null 2>&1 && echo "$b"; done', "sh"]
      .concat(root.supportedBackends)
    stdout: StdioCollector {
      onStreamFinished: {
        root.installedBackends = this.text.split("\n").filter(name => name !== "")
        // Brings the wallpaper back after login.
        if (root.backend !== "") daemonStart.running = true
      }
    }
  }

  Process {
    id: daemonStart
    command: ["sh", "-c", root.withDaemon, "sh", root.backend]
  }

  Process {
    id: scanProcess

    property var found: []
    property bool again: false

    stdout: SplitParser {
      onRead: line => {
        if (line.startsWith("#total ")) {
          root.scanTotal = parseInt(line.slice(7)) || 0
          return
        }
        const fields = line.split("\t")
        if (fields.length < 6) return
        const path = fields[0]
        const name = path.startsWith(root.folder + "/") ? path.slice(root.folder.length + 1) : path.split("/").pop()
        const extension = name.includes(".") ? name.split(".").pop().toUpperCase() : ""
        scanProcess.found.push({
          path: path,
          name: name,
          format: extension === "JPEG" ? "JPG" : extension,
          mtime: Number(fields[1]),
          bytes: Number(fields[2]),
          width: Number(fields[3]),
          height: Number(fields[4]),
          thumbnail: fields[5]
        })
        root.scanDone++
      }
    }

    onExited: {
      root.entries = scanProcess.found
      scanProcess.found = []
      root.scanning = false
      if (scanProcess.again) {
        scanProcess.again = false
        root.rescan()
      }
    }
  }

  Process {
    id: applyProcess

    property string path: ""
    property string queued: ""

    stderr: StdioCollector { id: applyErrors }

    onExited: exitCode => {
      if (exitCode === 0)
        currentFile.setText(applyProcess.path + "\n")
      else
        root.notify("Couldn't set the wallpaper", applyErrors.text.trim() || root.backend + " failed")
      if (applyProcess.queued !== "") {
        const next = applyProcess.queued
        applyProcess.queued = ""
        root.apply(next)
      }
    }
  }

  // Written in place, the way waypaper did, so MatugenService's watch sees it.
  FileView {
    id: currentFile
    path: root.home + "/.config/peridot/settings/current_wallpaper.txt"
    atomicWrites: false
    printErrors: false
  }

  // A new folder or the subfolder switch lists the images again.
  Timer {
    id: rescanTimer
    interval: 300
    onTriggered: root.rescan()
  }

  Connections {
    target: Settings

    function onWallpaperFolderChanged() {
      if (root.initialized) rescanTimer.restart()
    }

    function onWallpaperSubfoldersChanged() {
      if (root.initialized) rescanTimer.restart()
    }
  }
}
