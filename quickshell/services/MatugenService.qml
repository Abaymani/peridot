pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Themes everything from the wallpaper with matugen whenever
// current_wallpaper.txt changes.
//
// At startup it only runs if the wallpaper, mode or source color differ from
// the last run.
Singleton {
  id: root

  readonly property string stampPath: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache")
    + "/peridot/matugen-stamp"
  // The wallpaper read at startup, waiting for the settings to load.
  property string startupWallpaper: ""
  property bool started: false

  FileView {
    path: Quickshell.env("HOME") + "/.config/peridot/settings/current_wallpaper.txt"
    watchChanges: true
    onFileChanged: reload()

    onLoaded: {
      const newPath = text().trim();
      if (newPath === "") return;
      Settings.currentWallpaper = newPath;
      if (root.started) {
        root.runMatugen();
        return;
      }
      root.started = true;
      root.startupWallpaper = newPath;
      root.checkStartup();
    }
  }

  // What the last successful run was made from.
  FileView {
    id: stamp
    path: root.stampPath
    blockAllReads: true
    printErrors: false
  }

  Connections {
    target: Settings.store

    function onReadyChanged() {
      root.checkStartup();
    }
  }

  function stampFor(path: string): string {
    return [path, Settings.isDarkMode ? "dark" : "light", Settings.matugenSourceColorIndex].join("\n");
  }

  function checkStartup(): void {
    if (startupWallpaper === "" || !Settings.store.ready) return;
    const unchanged = stamp.text().trim() === stampFor(startupWallpaper);
    startupWallpaper = "";
    if (!unchanged) runMatugen();
  }

  function runMatugen() {
    if (Settings.currentWallpaper === "") return;

    const mode = Settings.isDarkMode ? "dark" : "light";

    // The stamp is written only if matugen succeeds.
    Quickshell.execDetached([
      "sh", "-c",
      'matugen image "$1" --source-color-index "$2" -m "$3" && mkdir -p "${4%/*}" && printf "%s\\n" "$5" > "$4"',
      "sh",
      Settings.currentWallpaper,
      String(Settings.matugenSourceColorIndex),
      mode,
      root.stampPath,
      root.stampFor(Settings.currentWallpaper)
    ]);

    Quickshell.execDetached([
      "notify-send",
      " running matugen!"
    ]);
  }

  function init() {}
}
