pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs

Singleton {
  id: root

  FileView {
    path: Quickshell.env("HOME") + "/.config/peridot/settings/current_wallpaper.txt"
    watchChanges: true
    onFileChanged: reload()

    onLoaded: {
      const newPath = text().trim();
      if (newPath !== "") {
          Settings.currentWallpaper = newPath;
          runMatugen()
      }
    }
  }

  function runMatugen() {
    if (Settings.currentWallpaper === "") return;

    const mode = Settings.isDarkMode ? "dark" : "light";
    
    Quickshell.execDetached([
      "matugen", 
      "image", 
      Settings.currentWallpaper, 
      "--source-color-index",
      Settings.matugenSourceColorIndex,
      "-m", mode
    ]);

    Quickshell.execDetached([
      "notify-send",
      " running matugen!"
    ]);
  }

  function init() {}
}
