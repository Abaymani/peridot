import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs.widgets
import qs

// The launcher's contents: search box, mode switch (apps, files, clipboard)
// and details toggle; bookmarked apps as one row of tiles until you type;
// results; key hints; and the details pane. Launcher.qml shows it in an
// OverlayPanel.
Item {
  id: root

  // 0: apps, 1: files, 2: clipboard.
  property int mode: 0
  property alias query: search.text
  readonly property alias navigator: nav
  readonly property string highlightColor: Looks.Colors.md3.primary_fixed
  readonly property bool showDetails: Settings.launcherDetailsPane

  // 0 with the details pane hidden, 1 with it shown. The list column, the
  // pane and the launcher's width all follow it, so the pane slides open or
  // shut in step with the card.
  property real paneShown: showDetails ? 1 : 0
  Behavior on paneShown {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }

  readonly property var bookmarks: mode === 0 && query === "" ? AppBookmarks.entries : []
  readonly property var results: mode === 0 ? Apps.search(query)
    : mode === 1 ? FileSearch.results
    : ClipboardService.search(query)
  readonly property var current: targetAt(nav.currentIndex)

  // Clearing the clipboard history takes a second click within 3 seconds.
  property bool confirmWipe: false

  signal closeRequested()

  implicitWidth: 560 + 200 * paneShown
  implicitHeight: 480

  // Called each time the launcher opens, on `startMode` (apps if not given).
  function reset(startMode) {
    search.text = ""
    setMode(startMode || 0)
    search.forceActiveFocus()
  }

  function setMode(newMode) {
    mode = newMode
    modeSwitch.selectedIndex = newMode
    nav.currentIndex = 0
    confirmWipe = false
    if (newMode === 1) FileSearch.reindex()
    if (newMode === 2) ClipboardService.refresh()
    FileSearch.search(newMode === 1 ? query : "")
  }

  // What's at navigator index `index`: { app: DesktopEntry }, { file: a
  // FileSearch result }, { clip: a ClipboardService entry }, or null.
  function targetAt(index) {
    if (index < bookmarks.length) return { app: bookmarks[index] }
    const result = results[index - bookmarks.length]
    if (!result) return null
    if (result.entry) return { app: result.entry }
    if (result.clip) return { clip: result.clip }
    return { file: result }
  }

  // Launches an app, opens a file (its folder with Ctrl), or copies a
  // clipboard entry.
  function open(target, modifiers) {
    if (!target) return
    closeRequested()
    if (target.app) Apps.launch(target.app)
    else if (target.clip) ClipboardService.copy(target.clip)
    else if (modifiers & Qt.ControlModifier) FileSearch.openFolder(target.file.path)
    else FileSearch.open(target.file.path)
  }

  // Keys beyond the navigator's: Tab and Shift+Tab cycle the modes, Ctrl+B
  // toggles an app's bookmark, Shift+Delete removes a clipboard entry (as it
  // removes a suggestion in browsers).
  function handleKey(event) {
    if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
      setMode((mode + (event.key === Qt.Key_Backtab ? 2 : 1)) % 3)
      return true
    }
    if (event.key === Qt.Key_B && (event.modifiers & Qt.ControlModifier)) {
      if (current && current.app) AppBookmarks.toggle(current.app.id)
      return true
    }
    if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ShiftModifier) && current && current.clip) {
      ClipboardService.remove(current.clip)
      return true
    }
    return false
  }

  onQueryChanged: {
    nav.currentIndex = 0
    if (mode === 1) FileSearch.search(query)
  }

  KeyNavigator {
    id: nav
    sections: [{ count: root.bookmarks.length, columns: AppBookmarks.max }, { count: root.results.length }]
    onActivated: (index, modifiers) => root.open(root.targetAt(index), modifiers)
    onCurrentIndexChanged: {
      const row = currentIndex - root.bookmarks.length
      if (row >= 0) list.positionViewAtIndex(row, ListView.Contain)
    }
  }

  Timer {
    id: wipeTimer
    interval: 3000
    onTriggered: root.confirmWipe = false
  }

  // The list column and the pane are placed by hand, so their widths track
  // paneShown exactly.
  ColumnLayout {
    id: main
    x: 10
    y: 10
    // 540 on its own, 450 beside the pane.
    width: 540 - 90 * root.paneShown
    height: root.height - 20
    spacing: 8

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      SearchBox {
        id: search
        Layout.fillWidth: true
        placeholderText: ["Search apps", "Search files", "Search clipboard"][root.mode]
        navigator: nav
        keyFilter: root.handleKey
      }

      // Icons only, like the control center's: three labelled modes and the
      // search box don't fit beside the details pane. The placeholder names
      // the mode.
      RadioBtnGroup {
        id: modeSwitch
        options: ["\u{f003b}", "\u{f0214}", "\u{f014d}"]
        fontSizeModifier: 3
        buttonHeight: search.implicitHeight
        onSelectionChanged: index => {
          root.setMode(index)
          search.forceActiveFocus()
        }
      }

      Button {
        Layout.preferredHeight: search.implicitHeight
        toggleButton: true
        checked: root.showDetails
        buttonText: "\u{f10ab}"
        fontSizeModifier: 3
        widthPadding: 18
        onClicked: {
          Settings.launcherDetailsPane = !Settings.launcherDetailsPane
          Settings.store.saveKey("launcherDetailsPane")
          search.forceActiveFocus()
        }
      }
    }

    // Bookmarks: apps only, one row, until something is typed.
    ColumnLayout {
      Layout.fillWidth: true
      visible: root.bookmarks.length > 0
      spacing: 4

      SectionLabel {
        text: "Bookmarks " + AppBookmarks.entries.length + "/" + AppBookmarks.max
      }

      // A plain Item, whose implicit width stays 0: a Row of the tiles would
      // report their total width, which the layout takes as the column's
      // minimum - so the column could widen with the tiles but never narrow.
      Item {
        id: tileRow
        Layout.fillWidth: true
        implicitHeight: 72

        Row {
          spacing: 4

          Repeater {
            model: root.bookmarks

            delegate: ResultTile {
              required property var modelData
              required property int index

              width: (tileRow.width - 4 * (AppBookmarks.max - 1)) / AppBookmarks.max
              icon: modelData.icon
              title: modelData.name
              selected: nav.currentIndex === index
              onPointed: nav.currentIndex = index
              onClicked: root.open({ app: modelData }, 0)
            }
          }
        }
      }
    }

    // "All apps" under the bookmarks, or the clipboard's size and Clear button.
    RowLayout {
      Layout.fillWidth: true
      visible: root.bookmarks.length > 0 || (root.mode === 2 && ClipboardService.entries.length > 0)
      spacing: 8

      SectionLabel {
        text: root.mode === 2 ? "History " + ClipboardService.entries.length : "All apps"
      }

      Item { Layout.fillWidth: true }

      Button {
        visible: root.mode === 2
        Layout.preferredHeight: 22
        buttonText: root.confirmWipe ? "Clear all?" : "\u{f0a7a}  Clear"
        fontSizeModifier: -2
        widthPadding: 14
        onClicked: {
          if (root.confirmWipe) {
            root.confirmWipe = false
            ClipboardService.wipe()
          } else {
            root.confirmWipe = true
            wipeTimer.restart()
          }
          search.forceActiveFocus()
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
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        model: root.results

        delegate: ResultRow {
          id: row
          required property var modelData
          required property int index
          readonly property int navIndex: root.bookmarks.length + index
          readonly property var app: modelData.entry ?? null
          readonly property var clip: modelData.clip ?? null
          readonly property bool bookmarked: app !== null && AppBookmarks.has(app.id)
          // A clipboard entry's line: an image's format, or the text from
          // around the match.
          readonly property var clipLine: clip === null ? null
            : clip.image ? { text: clip.image.format.toUpperCase() + " image", positions: [] }
            : ClipboardService.excerpt(clip.text, modelData.positions)

          width: ListView.view.width
          selected: nav.currentIndex === navIndex
          icon: app ? app.icon : ""
          image: !app && !clip && modelData.isImage ? modelData.path : ""
          glyph: app ? "\u{f08c6}" : clip ? (clip.image ? "\u{f021f}" : "\u{f014d}") : FileSearch.glyphFor(modelData)
          title: app ? FuzzySearch.highlight(app.name, modelData.namePositions, root.highlightColor)
            : clip ? FuzzySearch.highlight(clipLine.text, clipLine.positions, root.highlightColor)
            : FuzzySearch.highlight(modelData.name, modelData.namePositions, root.highlightColor)
          subtitle: app ? FuzzySearch.highlight(Apps.subtitle(app), modelData.subtitlePositions, root.highlightColor)
            : clip ? (clip.image ? FuzzySearch.escapeText(clip.image.width + " × " + clip.image.height + " · " + clip.image.size) : "")
            : FuzzySearch.highlight(modelData.dir, modelData.dirPositions, root.highlightColor)
          onPointed: nav.currentIndex = navIndex
          onClicked: root.open(root.targetAt(navIndex), 0)

          Looks.ClearText {
            visible: row.app !== null && row.app.runInTerminal
            text: "\u{f018d}"
            opacity: 0.6
            font.pixelSize: Looks.Fonts.size + 2
            color: Settings.textColorOnContainer
          }

          Looks.ClearText {
            visible: row.app !== null && (row.bookmarked || row.selected || row.hovered)
            text: row.bookmarked ? "\u{f00c0}" : "\u{f00c3}"
            opacity: row.bookmarked ? 0.95 : AppBookmarks.full ? 0.2 : 0.5
            font.pixelSize: Looks.Fonts.size + 4
            color: Settings.textColorOnContainer

            MouseArea {
              anchors.fill: parent
              anchors.margins: -4
              cursorShape: Qt.PointingHandCursor
              onClicked: AppBookmarks.toggle(row.app.id)
            }
          }

          Looks.ClearText {
            visible: row.clip !== null && (row.selected || row.hovered)
            text: "\u{f0a7a}"
            opacity: 0.6
            font.pixelSize: Looks.Fonts.size + 3
            color: Settings.textColorOnContainer

            MouseArea {
              anchors.fill: parent
              anchors.margins: -4
              cursorShape: Qt.PointingHandCursor
              onClicked: ClipboardService.remove(row.clip)
            }
          }
        }
      }

      FastScrollArea {
        anchors.fill: parent
        target: list
      }

      Looks.ClearText {
        anchors.centerIn: parent
        width: parent.width - 40
        visible: list.count === 0
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        opacity: 0.6
        text: root.query !== "" ? "No matches"
          : root.mode === 1 ? "Type to search " + FileSearch.rootNames.join(", ")
          : root.mode === 2 ? "Clipboard history is empty"
          : "No apps found"
        color: Settings.textColorOnContainer
      }
    }

    KeyHints {
      Layout.leftMargin: 4
      keys: [
        [["↑↓", "select"], ["↵", "open"], ["Ctrl B", "bookmark"], ["Tab", "files"]],
        [["↑↓", "select"], ["↵", "open"], ["Ctrl ↵", "folder"], ["Tab", "clipboard"]],
        [["↑↓", "select"], ["↵", "copy"], ["Shift Del", "remove"], ["Tab", "apps"]]
      ][root.mode]
    }
  }

  // The pane at its full width, clipped while it slides open or shut.
  Item {
    x: main.x + main.width
    y: 10
    width: 290 * root.paneShown
    height: root.height - 20
    visible: width > 0
    clip: true

    LauncherDetails {
      x: 10
      width: 280
      height: parent.height
      // Kept up to date even while the pane is closed; see LauncherDetails.
      target: root.current
      onOpenRequested: modifiers => root.open(root.current, modifiers)
      onActionTriggered: action => {
        root.closeRequested()
        action.execute()
      }
    }
  }
}
