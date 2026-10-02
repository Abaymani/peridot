import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs.widgets
import qs

// The emoji picker's contents: search, category tabs, the emoji by category
// (recently used first) or the search results, and the selected emoji's name.
Item {
  id: root

  readonly property int columns: 9
  readonly property int cellSize: 36
  property alias query: search.text
  readonly property alias navigator: nav
  readonly property alias list: list
  readonly property bool searching: query.trim() !== ""

  readonly property var tabGlyphs: ({
    "Recent": "\u{f02da}",
    "Smileys & Emotion": "\u{f01f5}",
    "People & Body": "\u{f0004}",
    "Animals & Nature": "\u{f03e9}",
    "Food & Drink": "\u{f025a}",
    "Travel & Places": "\u{f001d}",
    "Activities": "\u{f0806}",
    "Objects": "\u{f0335}",
    "Symbols": "\u{f02d1}",
    "Flags": "\u{f023b}"
  })
  readonly property var categoryGroups: (Emoji.recent.length > 0 ? [{ name: "Recent", emoji: Emoji.recent }] : [])
    .concat(Emoji.categories)
  readonly property var results: searching ? Emoji.search(query) : []
  readonly property var groups: searching
    ? [{ name: results.length === 0 ? "No matches" : results.length + (results.length === 1 ? " result" : " results"), emoji: results }]
    : categoryGroups
  // Every shown emoji in order; the navigator's index points into it.
  readonly property var flat: groups.reduce((all, group) => all.concat(group.emoji), [])
  // The list's rows: a header per group, then its emoji a row at a time.
  readonly property var rows: {
    const rows = []
    let start = 0
    groups.forEach((group, index) => {
      rows.push({ name: group.name, group: index })
      for (let i = 0; i < group.emoji.length; i += columns)
        rows.push({ emoji: group.emoji.slice(i, i + columns), start: start + i, group: index })
      start += group.emoji.length
    })
    return rows
  }
  readonly property var current: flat[nav.currentIndex] ?? null
  // The group at the top of the list, lit in the tabs.
  readonly property int topGroup: {
    const row = rows[list.indexAt(1, list.contentY + 1)]
    return row ? row.group : 0
  }
  // Set while the pointer moves the selection, so the list doesn't scroll under it.
  property bool pointing: false

  signal picked(var emoji)

  implicitWidth: columns * cellSize + 24
  implicitHeight: 420

  // Called each time the picker opens.
  function reset() {
    search.text = ""
    nav.currentIndex = 0
    list.positionViewAtBeginning()
    search.forceActiveFocus()
  }

  function rowOf(index) {
    return rows.findIndex(row => row.emoji && index >= row.start && index < row.start + row.emoji.length)
  }

  function jumpTo(group) {
    const header = rows.findIndex(row => !row.emoji && row.group === group)
    if (header < 0) return
    if (rows[header + 1]?.emoji) nav.currentIndex = rows[header + 1].start
    list.positionViewAtIndex(header, ListView.Beginning)
  }

  // Tab and Shift+Tab jump between categories.
  function handleKey(event) {
    if (event.key !== Qt.Key_Tab && event.key !== Qt.Key_Backtab) return false
    const row = rows[rowOf(nav.currentIndex)]
    const group = (row ? row.group : 0) + (event.key === Qt.Key_Tab ? 1 : -1)
    jumpTo((group + groups.length) % groups.length)
    return true
  }

  onQueryChanged: {
    nav.currentIndex = 0
    list.positionViewAtBeginning()
  }

  KeyNavigator {
    id: nav
    sections: root.groups.map(group => ({ count: group.emoji.length, columns: root.columns }))
    onActivated: index => {
      if (root.flat[index]) root.picked(root.flat[index])
    }
    onCurrentIndexChanged: {
      if (root.pointing) return
      const row = root.rowOf(currentIndex)
      if (row < 0) return
      list.positionViewAtIndex(row, ListView.Contain)
      // Keeps a category's heading in view along with its first row.
      if (row > 0 && !root.rows[row - 1].emoji) list.positionViewAtIndex(row - 1, ListView.Contain)
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 10

    SearchBox {
      id: search
      Layout.fillWidth: true
      placeholderText: "Search emoji"
      navigator: nav
      keyFilter: event => root.handleKey(event)
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 2
      enabled: !root.searching
      opacity: root.searching ? 0.4 : 1

      Repeater {
        model: root.categoryGroups

        Rectangle {
          id: tab
          required property var modelData
          required property int index
          readonly property bool active: !root.searching && index === root.topGroup

          Layout.fillWidth: true
          implicitHeight: 28
          radius: 8
          color: tabArea.containsMouse ? ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.1) : "transparent"

          Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Looks.Colors.md3.surface_container
            gradient: Settings.gradientBgEnabled
              ? Looks.Gradients.library[Settings.activeGradient].createObject()
              : null
            opacity: tab.active ? 1 : 0

            Behavior on opacity {
              NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
            }
          }

          Looks.ClearText {
            anchors.centerIn: parent
            text: root.tabGlyphs[tab.modelData.name] ?? "\u{f01f5}"
            font.pixelSize: Looks.Fonts.size + 3
            opacity: tab.active ? 1 : 0.7
            color: Settings.textColorOnContainer
          }

          MouseArea {
            id: tabArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.jumpTo(tab.index)
          }
        }
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      ListView {
        id: list
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: root.rows

        delegate: Item {
          id: row
          required property var modelData

          width: list.width
          height: modelData.emoji ? root.cellSize : 26

          SectionLabel {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            visible: !row.modelData.emoji
            text: row.modelData.name ?? ""
          }

          Row {
            visible: !!row.modelData.emoji

            Repeater {
              model: row.modelData.emoji ?? []

              EmojiCell {
                required property var modelData
                required property int index
                readonly property int navIndex: row.modelData.start + index

                glyph: modelData.glyph
                selected: nav.currentIndex === navIndex
                onPointed: {
                  root.pointing = true
                  nav.currentIndex = navIndex
                  root.pointing = false
                }
                onClicked: root.picked(modelData)
              }
            }
          }
        }
      }

      FastScrollArea {
        anchors.fill: list
        target: list
      }

      Rectangle {
        anchors.right: list.right
        y: list.visibleArea.yPosition * list.height
        width: 3
        height: list.visibleArea.heightRatio * list.height
        radius: 1.5
        visible: list.visibleArea.heightRatio < 1
        color: Settings.textColorOnContainer
        opacity: 0.35
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Text {
        text: root.current?.glyph ?? ""
        font.pixelSize: 18
        renderType: Text.NativeRendering
      }

      Looks.ClearText {
        Layout.fillWidth: true
        text: root.current?.name ?? ""
        elide: Text.ElideRight
        font.pixelSize: Looks.Fonts.size - 1
        color: Settings.textColorOnContainer
      }

      KeyHints {
        keys: [["↵", "copy"], ["Esc", "close"]]
      }
    }
  }
}
