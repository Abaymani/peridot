import QtQuick

// Keyboard selection for popups. Tracks `currentIndex` through sections laid
// out top to bottom - lists and grids - and moves it with the arrow and page
// keys. Forward key presses to handleKey() from whatever holds focus (SearchBox
// does this for you):
//
//     KeyNavigator {
//       id: nav
//       sections: [{ count: tiles.length, columns: 6 }, { count: rows.length }]
//       onActivated: (index, modifiers) => open(index)
//     }
QtObject {
  id: root

  // [{ count, columns }] top to bottom; indexes run through them in order.
  // `columns` defaults to 1, a list.
  property var sections: []
  property int currentIndex: 0
  // How many rows Page Up/Down move.
  property int pageRows: 8

  readonly property int count: sections.reduce((total, section) => total + section.count, 0)

  // Column remembered while passing through a list, for the next grid.
  property int gridColumn: 0

  // Enter on `index`; `modifiers` are the keyboard modifiers held.
  signal activated(int index, int modifiers)

  function select(index) {
    currentIndex = count === 0 ? 0 : Math.max(0, Math.min(count - 1, index))
  }

  // Every section's rows as { start, length, columns }.
  function rows() {
    const result = []
    let start = 0
    for (const section of sections) {
      const columns = section.columns || 1
      for (let i = 0; i < section.count; i += columns)
        result.push({ start: start + i, length: Math.min(columns, section.count - i), columns: columns })
      start += section.count
    }
    return result
  }

  // Moves `delta` rows down (up if negative), across sections, keeping the
  // grid column where there is one.
  function moveRows(delta) {
    const all = rows()
    if (all.length === 0) return
    let row = all.findIndex(r => currentIndex < r.start + r.length)
    if (row < 0) row = all.length - 1
    if (all[row].columns > 1) gridColumn = currentIndex - all[row].start
    const target = all[Math.max(0, Math.min(all.length - 1, row + delta))]
    currentIndex = target.start + (target.columns > 1 ? Math.min(gridColumn, target.length - 1) : 0)
  }

  // Moves along the current grid row. Returns false in a list, so a text
  // field keeps its cursor keys.
  function moveColumns(delta) {
    const row = rows().find(r => currentIndex < r.start + r.length)
    if (!row || row.columns === 1) return false
    gridColumn = Math.max(0, Math.min(row.length - 1, currentIndex - row.start + delta))
    currentIndex = row.start + gridColumn
    return true
  }

  // Handles a navigation key; returns whether it was used.
  function handleKey(event) {
    switch (event.key) {
    case Qt.Key_Up: moveRows(-1); return true
    case Qt.Key_Down: moveRows(1); return true
    case Qt.Key_PageUp: moveRows(-pageRows); return true
    case Qt.Key_PageDown: moveRows(pageRows); return true
    case Qt.Key_Left: return moveColumns(-1)
    case Qt.Key_Right: return moveColumns(1)
    case Qt.Key_Return:
    case Qt.Key_Enter:
      if (count > 0) activated(currentIndex, event.modifiers)
      return true
    }
    return false
  }

  onCountChanged: select(currentIndex)
}
