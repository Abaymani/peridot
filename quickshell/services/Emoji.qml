pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Emoji for the picker (common/emoji/emoji.json, see generate.py there):
// categories, search, recently used and copying.
Singleton {
  id: root

  readonly property int recentMax: 9
  // [{ name, emoji: [{ glyph, name, keywords }] }]
  property var categories: []
  // Newest first. Replaced, never mutated, so bindings on it update.
  property var recentGlyphs: []
  readonly property var recent: recentGlyphs.map(glyph => byGlyph[glyph]).filter(emoji => !!emoji)

  property var all: []
  property var byGlyph: ({})

  // Emoji matching every word of `query` at the start of a word in their
  // name or keywords, best first: whole and leading name matches first.
  function search(query) {
    const words = query.toLowerCase().split(/\s+/).filter(word => word)
    if (words.length === 0) return []
    const hits = []
    all.forEach((emoji, index) => {
      let score = 0
      for (const word of words) {
        const s = wordScore(emoji, word)
        if (s === 0) return
        score += s
      }
      hits.push({ emoji: emoji, score: score, index: index })
    })
    return hits.sort((a, b) => b.score - a.score || a.index - b.index).map(hit => hit.emoji)
  }

  function wordScore(emoji, word) {
    if (emoji.lowerName === word) return 100
    if (emoji.lowerName.startsWith(word)) return 60
    if ((" " + emoji.lowerName).includes(" " + word)) return 40
    if ((" " + emoji.keywords).includes(" " + word)) return 30
    return 0
  }

  function copy(emoji) {
    Quickshell.execDetached(["wl-copy", "--", emoji.glyph])
    recentGlyphs = [emoji.glyph].concat(recentGlyphs.filter(glyph => glyph !== emoji.glyph)).slice(0, recentMax)
    recentFile.setText(JSON.stringify({ recent: recentGlyphs }) + "\n")
  }

  FileView {
    path: Quickshell.shellPath("common/emoji/emoji.json")
    onLoaded: {
      const categories = []
      const all = []
      const byGlyph = {}
      for (const category of JSON.parse(text()).categories) {
        const emoji = category.emoji.map(([glyph, name, keywords]) =>
          ({ glyph: glyph, name: name, lowerName: name.toLowerCase().replace(/[-:,]+/g, " "), keywords: keywords }))
        categories.push({ name: category.name, emoji: emoji })
        for (const e of emoji) {
          all.push(e)
          byGlyph[e.glyph] = e
        }
      }
      root.all = all
      root.byGlyph = byGlyph
      root.categories = categories
    }
  }

  // Read once, then only written, as in AppBookmarks.
  FileView {
    id: recentFile
    path: Quickshell.env("HOME") + "/.config/peridot/.cache/emoji.json"
    blockAllReads: true
    printErrors: false
  }

  Component.onCompleted: {
    try {
      const saved = JSON.parse(recentFile.text())
      if (Array.isArray(saved.recent)) recentGlyphs = saved.recent.slice(0, recentMax)
    } catch (e) {
      // No recents yet.
    }
  }
}
