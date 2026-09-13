pragma Singleton
import Quickshell

// fzf-style fuzzy matching for search boxes: match() scores text against a
// query and reports which characters matched; highlight() marks those up.
Singleton {
  /**
  * Scores `text` against `query`; a score of 0 means no match. A contiguous
  * match beats a scattered one, and matches at word starts and near the front
  * score higher.
  * @param {string} query
  * @param {string} text
  * @param {bool} substringOnly - only accept `query` as one contiguous run
  * @returns {{score: number, positions: int[]}} with the matched characters' indexes
  */
  function match(query, text, substringOnly) {
    if (!query) return { score: 1, positions: [] }
    if (!text) return { score: 0, positions: [] }
    const q = query.toLowerCase()
    const t = text.toLowerCase()
    const wordStart = i => i === 0 || " -_./".includes(t[i - 1])
      || (text[i] !== t[i] && text[i - 1] === t[i - 1])

    const first = t.indexOf(q)
    if (first >= 0) {
      let at = first
      for (let i = first; i >= 0; i = t.indexOf(q, i + 1)) {
        if (wordStart(i)) { at = i; break }
      }
      const positions = []
      for (let i = 0; i < q.length; i++) positions.push(at + i)
      const bonus = at === 0 ? 40 : wordStart(at) ? 25 : 0
      // Penalties are capped, so a match deep in a long text (a clipboard
      // entry, say) still scores above 0.
      return { score: 100 + bonus + q.length * 4 - Math.min(at, 60) * 0.5 - Math.min(t.length, 200) * 0.1, positions: positions }
    }
    if (substringOnly) return { score: 0, positions: [] }

    // Scattered: each query character at the next word start holding it, else
    // at its next occurrence.
    let from = 0, previous = -2, score = 0
    const positions = []
    for (const c of q) {
      let found = -1
      for (let j = from; j < t.length; j++) {
        if (t[j] !== c) continue
        if (found < 0) found = j
        if (wordStart(j)) { found = j; break }
      }
      if (found < 0) return { score: 0, positions: [] }
      score += 10 + (found === previous + 1 ? 12 : 0) + (wordStart(found) ? 15 : 0) - Math.min(found - from, 12)
      positions.push(found)
      previous = found
      from = found + 1
    }
    return { score: Math.max(1, score * 0.8 - t.length * 0.1), positions: positions }
  }

  /**
  * `text` as StyledText, with the characters at `positions` bold and in `color`.
  * @param {string} text
  * @param {int[]} positions
  * @param {string} color
  * @returns {string}
  */
  function highlight(text, positions, color) {
    if (!text) return ""
    if (!positions || positions.length === 0) return escapeText(text)
    const hit = new Set(positions)
    let out = "", run = ""
    const flush = () => {
      if (run) out += '<b><font color="' + color + '">' + escapeText(run) + "</font></b>"
      run = ""
    }
    for (let i = 0; i < text.length; i++) {
      if (hit.has(i)) {
        run += text[i]
      } else {
        flush()
        out += escapeText(text[i])
      }
    }
    flush()
    return out
  }

  /**
  * `text` made safe to show as StyledText.
  * @param {string} text
  * @returns {string}
  */
  function escapeText(text) {
    return String(text).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }
}
