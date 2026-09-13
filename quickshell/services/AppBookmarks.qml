pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The launcher's bookmarked apps (desktop entry ids), in the order added.
// Capped at `max`, since they show as a single row of tiles.
Singleton {
  id: root

  readonly property int max: 6
  // Replaced, never mutated, so bindings on it update.
  property var ids: []
  readonly property bool full: ids.length >= max
  // Bookmarked apps that are still installed.
  readonly property var entries: {
    DesktopEntries.applications.values // re-check when apps are installed or removed
    return ids.map(id => DesktopEntries.byId(id)).filter(entry => !!entry).slice(0, max)
  }

  function has(id) {
    return ids.includes(id)
  }

  // Adds or removes `id`. Returns false if the row is full and `id` isn't in it.
  function toggle(id) {
    if (has(id))
      ids = ids.filter(other => other !== id)
    else if (full)
      return false
    else
      ids = ids.concat([id])
    file.setText(JSON.stringify({ ids: ids }, null, 4) + "\n")
    return true
  }

  // Read once at startup, then only written. There's no JsonAdapter because
  // a FileView re-applies each write to its adapter when the write finishes,
  // which undid toggles made in quick succession.
  FileView {
    id: file
    path: Quickshell.env("HOME") + "/.config/peridot/.cache/launcher.json"
    // So text() below returns the file straight away.
    blockAllReads: true
    // A missing file only means there are no bookmarks yet.
    printErrors: false
  }

  Component.onCompleted: {
    try {
      const saved = JSON.parse(file.text())
      if (Array.isArray(saved.ids)) ids = saved.ids
    } catch (e) {
      // No file yet, or not JSON: start with no bookmarks.
    }
  }
}
