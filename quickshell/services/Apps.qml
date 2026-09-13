pragma Singleton
import QtQuick
import Quickshell
import qs.common.functions

// Installed apps for the launcher: fuzzy search and launching.
Singleton {
  id: root

  // For apps whose desktop entry sets Terminal=true, which
  // DesktopEntry.execute() ignores.
  property string terminal: "kitty"

  // Every launchable app (Hidden/NoDisplay entries are left out), by name.
  readonly property var all: Array.from(DesktopEntries.applications.values)
    .sort((a, b) => a.name.localeCompare(b.name))

  // The line under an app's name.
  function subtitle(entry) {
    return entry.genericName || entry.comment || ""
  }

  // Apps matching `query`, best first, with bookmarked ones boosted, as
  // { entry, namePositions, subtitlePositions }. Names match fuzzily;
  // descriptions and keywords only as a whole substring, since loose matches
  // in long text are mostly noise. An empty query lists every app.
  function search(query) {
    if (query === "")
      return all.map(entry => ({ entry: entry, namePositions: [], subtitlePositions: [] }))

    const hits = []
    for (const entry of all) {
      const byName = FuzzySearch.match(query, entry.name)
      const bySubtitle = FuzzySearch.match(query, subtitle(entry), true)
      const byKeywords = FuzzySearch.match(query, Array.from(entry.keywords).join(" "), true)
      let score = Math.max(byName.score, bySubtitle.score * 0.6, byKeywords.score * 0.5)
      if (score <= 0) continue
      if (AppBookmarks.has(entry.id)) score += 30
      hits.push({
        entry: entry,
        score: score,
        namePositions: byName.positions,
        subtitlePositions: byName.score > 0 ? [] : bySubtitle.positions
      })
    }
    return hits.sort((a, b) => b.score - a.score)
  }

  function launch(entry) {
    if (entry.runInTerminal) {
      Quickshell.execDetached({
        command: [root.terminal, "-e"].concat(Array.from(entry.command)),
        workingDirectory: entry.workingDirectory
      })
    } else {
      entry.execute()
    }
  }
}
