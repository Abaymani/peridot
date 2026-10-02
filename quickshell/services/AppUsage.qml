pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// How often each app was launched from the launcher, by desktop entry id.
Singleton {
  id: root

  // Replaced, never mutated, so bindings on it update.
  property var counts: ({})

  function count(id) {
    return counts[id] ?? 0
  }

  function record(id) {
    counts = Object.assign({}, counts, { [id]: count(id) + 1 })
    file.setText(JSON.stringify({ counts: counts }, null, 4) + "\n")
  }

  // Read once, then only written, as in AppBookmarks.
  FileView {
    id: file
    path: Quickshell.env("HOME") + "/.config/peridot/.cache/app-usage.json"
    blockAllReads: true
    printErrors: false
  }

  // wofi's launch counts, used to start from on the first run.
  FileView {
    id: wofiHistory
    path: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/wofi-drun"
    blockAllReads: true
    printErrors: false
  }

  Component.onCompleted: {
    try {
      const saved = JSON.parse(file.text())
      if (saved.counts && typeof saved.counts === "object") counts = saved.counts
      return
    } catch (e) {
      // No file yet: seed from wofi below.
    }

    const seeded = {}
    for (const line of wofiHistory.text().split("\n")) {
      // "<count> /path/to/<id>.desktop"
      const match = line.match(/^(\d+) .*\/([^\/]+)\.desktop$/)
      if (match) seeded[match[2]] = (seeded[match[2]] ?? 0) + Number(match[1])
    }
    if (Object.keys(seeded).length === 0) return
    counts = seeded
    file.setText(JSON.stringify({ counts: counts }, null, 4) + "\n")
  }
}
