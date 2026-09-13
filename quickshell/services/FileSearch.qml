pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import qs.common.functions

// File search for the launcher. There's no fd, ripgrep or plocate installed,
// so reindex() lists the XDG user folders with find (skipping hidden files and
// node_modules) into a cache file, and each search ranks that list with
// `fzf --filter --scheme=path`.
Singleton {
  id: root

  readonly property string home: Quickshell.env("HOME")
  // The folders searched. An XDG folder that's set to $HOME itself is left
  // out; it would pull in everything, ~/repos included.
  readonly property var roots: {
    const locations = [StandardPaths.DesktopLocation, StandardPaths.DocumentsLocation, StandardPaths.DownloadLocation,
      StandardPaths.MusicLocation, StandardPaths.PicturesLocation, StandardPaths.MoviesLocation]
    const paths = locations.map(l => decodeURIComponent(String(StandardPaths.writableLocation(l)).replace(/^file:\/\//, "")))
    return paths.filter((p, i) => p.replace(/\/$/, "") !== home && paths.indexOf(p) === i)
  }
  readonly property var rootNames: roots.map(p => p.substring(p.lastIndexOf("/") + 1))
  property int maxResults: 50
  readonly property string listPath: Quickshell.cachePath("launcher-files.txt")

  property string query: ""
  // Best first, as { path, name, dir (with ~), isDir, isImage, namePositions, dirPositions }.
  property var results: []
  // Size and date of the file last passed to describe(), as { path, size, modified }.
  property var info: ({})

  function reindex() {
    indexer.running = false
    indexer.running = true
  }

  // Ranks the file list against `text`; the matches land in `results`.
  function search(text) {
    query = text
    if (text === "") {
      debounce.stop()
      results = []
    } else {
      debounce.restart()
    }
  }

  function open(path) {
    Quickshell.execDetached(["xdg-open", path])
  }

  function openFolder(path) {
    Quickshell.execDetached(["xdg-open", path.substring(0, path.lastIndexOf("/")) || "/"])
  }

  // Looks up `path`'s size and date for `info`.
  function describe(path) {
    describer.running = false
    describer.command = ["sh", "-c", 'printf "%s\\t" "$1"; stat --printf "%s\\t%Y" -- "$1"', "sh", path]
    describer.running = true
  }

  function glyphFor(result) {
    if (result.isDir) return "\u{f024b}"
    if (result.isImage) return "\u{f021f}"
    const ext = result.name.includes(".") ? result.name.split(".").pop().toLowerCase() : ""
    if (["qml", "js", "ts", "py", "lua", "sh", "fish", "c", "h", "cpp", "rs", "go", "java", "cs",
         "json", "toml", "yaml", "yml", "css", "html"].includes(ext)) return "\u{f022e}"
    if (["md", "txt", "ini", "conf", "log"].includes(ext)) return "\u{f0219}"
    if (ext === "pdf") return "\u{f0226}"
    if (["mp3", "flac", "ogg", "opus", "wav", "m4a"].includes(ext)) return "\u{f0223}"
    if (["mp4", "mkv", "webm", "mov", "avi"].includes(ext)) return "\u{f022b}"
    if (["zip", "tar", "gz", "xz", "zst", "7z", "rar"].includes(ext)) return "\u{f05c4}"
    return "\u{f0214}"
  }

  function formatSize(bytes) {
    const units = ["B", "KB", "MB", "GB", "TB"]
    let i = 0
    while (bytes >= 1024 && i < units.length - 1) {
      bytes /= 1024
      i++
    }
    return (i === 0 ? bytes : bytes.toFixed(1)) + " " + units[i]
  }

  function toResult(line) {
    const isDir = line.endsWith("/")
    const path = isDir ? line.slice(0, -1) : line
    const slash = path.lastIndexOf("/")
    const name = path.substring(slash + 1)
    const parent = path.substring(0, slash)
    const dir = parent.startsWith(home) ? "~" + parent.substring(home.length) : parent
    const byName = FuzzySearch.match(query, name)
    return {
      path: path,
      name: name,
      dir: dir,
      isDir: isDir,
      isImage: !isDir && /\.(png|jpe?g|gif|webp|bmp|svg)$/i.test(name),
      namePositions: byName.positions,
      dirPositions: byName.score > 0 ? [] : FuzzySearch.match(query, dir).positions
    }
  }

  Timer {
    id: debounce
    interval: 60
    onTriggered: {
      searcher.running = false
      // The first output line echoes the query, so results of a search that
      // was overtaken can be told apart.
      searcher.command = ["sh", "-c", 'printf "%s\\n" "$1"; fzf --filter "$1" --scheme=path < "$2" | head -n "$3"',
        "sh", root.query, root.listPath, String(root.maxResults)]
      searcher.running = true
    }
  }

  // Directories get a trailing slash, which fzf's path scheme understands.
  Process {
    id: indexer
    command: ["sh", "-c", `out=$1; shift
[ $# -gt 0 ] || exit 0
mkdir -p "$(dirname "$out")"
find -H "$@" \\( -name '.*' -o -name node_modules \\) -prune -o -type d -printf '%p/\\n' -o -type f -print > "$out.tmp" 2>/dev/null
mv "$out.tmp" "$out"`, "sh", root.listPath].concat(root.roots)
    onExited: if (root.query !== "") debounce.restart()
  }

  Process {
    id: searcher
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.split("\n")
        if (lines.shift() !== root.query) return
        root.results = lines.filter(line => line !== "").map(line => root.toResult(line))
      }
    }
  }

  Process {
    id: describer
    stdout: StdioCollector {
      onStreamFinished: {
        const fields = text.split("\t")
        if (fields.length < 3) return
        const modified = Number(fields.pop())
        const size = Number(fields.pop())
        root.info = { path: fields.join("\t"), size: size, modified: new Date(modified * 1000) }
      }
    }
  }
}
