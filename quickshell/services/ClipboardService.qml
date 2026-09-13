pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.functions

// Clipboard history from cliphist, for the launcher's Clipboard mode: newest
// first, refreshed whenever the clipboard changes.
Singleton {
  id: root

  // How much of each entry `cliphist list` shows (it joins lines with spaces).
  // Wider than its default of 100, so search reaches further into long entries.
  property int previewWidth: 1000
  readonly property string previewDir: Quickshell.cachePath("clipboard")

  // Newest first, as { line, id, text, image }. `line` is cliphist's own
  // "id<TAB>preview", which decode and delete read back; `image` is
  // { format, size, width, height } for images, else null.
  property var entries: []
  // Full contents of the entry last passed to preview(): { id, text, length }
  // for text (text capped at 4000 characters), { id, imagePath } for images.
  property var shown: ({})

  // Lists again - after the current listing, if one is running, since a
  // listing cut short would hand back part of the history.
  function refresh() {
    if (lister.running) lister.again = true
    else lister.running = true
  }

  // Entries containing `query` (ignoring case), newest first, as { clip, positions }.
  function search(query) {
    const hits = []
    for (const entry of entries) {
      const match = FuzzySearch.match(query, entry.text, true)
      if (match.score > 0) hits.push({ clip: entry, positions: match.positions })
    }
    return hits
  }

  // `text` from a little before its first highlighted character, so a match
  // deep in a long entry stays in view, with `positions` shifted to suit.
  function excerpt(text, positions) {
    if (positions.length === 0 || positions[0] < 40) return { text: text, positions: positions }
    const start = positions[0] - 20
    return { text: "…" + text.substring(start), positions: positions.map(p => p - start + 1) }
  }

  // Puts `entry` back on the clipboard.
  function copy(entry) {
    Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist decode | wl-copy', "sh", entry.line])
  }

  function remove(entry) {
    entries = entries.filter(other => other.id !== entry.id)
    Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist delete; rm -f "$2/$3".*',
      "sh", entry.line, previewDir, entry.id])
  }

  // Deletes the whole history.
  function wipe() {
    entries = []
    shown = ({})
    Quickshell.execDetached(["sh", "-c", 'cliphist wipe; rm -rf "$1"', "sh", previewDir])
  }

  // Loads `entry`'s full contents into `shown`: its text, or for an image, a
  // file holding it (decoded once, into previewDir).
  function preview(entry) {
    if (!entry || shown.id === entry.id) return
    if (entry.text.startsWith("[[ binary data ") && !entry.image) {
      shown = { id: entry.id }
      return
    }
    previewer.running = false
    previewer.wanted = entry.id
    // The first output line echoes the id, so a preview that was overtaken
    // can be told apart.
    previewer.command = entry.image
      ? ["sh", "-c", 'printf "%s\\n" "$2"; mkdir -p "$3"; f="$3/$2.$4"; [ -s "$f" ] || printf "%s" "$1" | cliphist decode > "$f"; printf "%s" "$f"',
         "sh", entry.line, entry.id, previewDir, entry.image.format]
      : ["sh", "-c", 'printf "%s\\n" "$2"; printf "%s" "$1" | cliphist decode', "sh", entry.line, entry.id]
    previewer.running = true
  }

  function parse(line) {
    const tab = line.indexOf("\t")
    const text = line.substring(tab + 1)
    const binary = /^\[\[ binary data (.+) (\w+) (\d+)x(\d+) \]\]$/.exec(text)
    return {
      line: line,
      id: line.substring(0, tab),
      text: text,
      image: binary ? { size: binary[1], format: binary[2], width: Number(binary[3]), height: Number(binary[4]) } : null
    }
  }

  // Waits a moment after a clipboard change, so cliphist (fed by its own
  // wl-paste --watch) has stored the new entry before listing.
  Timer {
    id: debounce
    interval: 100
    onTriggered: root.refresh()
  }

  Process {
    command: ["wl-paste", "--watch", "echo", "update"]
    running: true
    stdout: SplitParser {
      onRead: debounce.restart()
    }
  }

  Process {
    id: lister
    property bool again: false
    command: ["cliphist", "-preview-width", String(root.previewWidth), "list"]
    running: true
    onExited: if (again) {
      again = false
      running = true
    }
    stdout: StdioCollector {
      onStreamFinished: {
        root.entries = text.split("\n").filter(line => line.includes("\t")).map(line => root.parse(line))
        // Drop decoded images whose entries have gone.
        const kept = root.entries.filter(entry => entry.image).map(entry => entry.id)
        Quickshell.execDetached(["sh", "-c",
          'cd "$1" 2>/dev/null || exit 0; shift; for f in *; do case " $* " in *" ${f%.*} "*) ;; *) rm -f -- "$f" ;; esac; done',
          "sh", root.previewDir].concat(kept))
      }
    }
  }

  Process {
    id: previewer
    property string wanted: ""
    stdout: StdioCollector {
      onStreamFinished: {
        const newline = text.indexOf("\n")
        const id = text.substring(0, newline)
        if (id !== previewer.wanted) return
        const body = text.substring(newline + 1)
        const entry = root.entries.find(e => e.id === id)
        root.shown = entry && entry.image
          ? { id: id, imagePath: body }
          : { id: id, text: body.substring(0, 4000), length: body.length }
      }
    }
  }
}
