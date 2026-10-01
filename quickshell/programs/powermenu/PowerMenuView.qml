import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

// The power menu's contents: who's logged in, a tile per action, key hints.
Item {
  id: root

  readonly property var actions: Session.actions
  readonly property alias navigator: nav

  signal activated(var action)

  implicitWidth: content.implicitWidth + 36
  implicitHeight: content.implicitHeight + 36

  // Called each time the menu opens.
  function reset() {
    nav.currentIndex = 0
    Session.refreshUptime()
    forceActiveFocus()
  }

  KeyNavigator {
    id: nav
    sections: [{ count: root.actions.length, columns: root.actions.length }]
    onActivated: index => root.activated(root.actions[index])
  }

  Keys.onPressed: event => {
    if (nav.handleKey(event)) {
      event.accepted = true
      return
    }
    const action = root.actions.find(action => action.key === event.text.toUpperCase())
    if (!action) return
    event.accepted = true
    root.activated(action)
  }

  ColumnLayout {
    id: content
    x: 18
    y: 18
    spacing: 16

    RowLayout {
      spacing: 10

      CircleImage {
        diameter: 36
        source: Settings.profilePicture !== "" ? "file://" + Settings.profilePicture : ""
      }

      ColumnLayout {
        spacing: 1

        Looks.ClearText {
          text: Session.user
          font.pixelSize: Looks.Fonts.size + 2
          font.bold: true
          color: Settings.textColorOnContainer
        }

        Looks.ClearText {
          text: [Session.host, Session.uptime].filter(part => part).join(" · ")
          font.pixelSize: Looks.Fonts.size - 1
          font.italic: true
          opacity: 0.8
          color: Settings.textColorOnContainer
        }
      }
    }

    Row {
      spacing: 8

      Repeater {
        model: root.actions

        PowerTile {
          required property var modelData
          required property int index

          glyph: modelData.glyph
          label: modelData.label
          key: modelData.key
          selected: nav.currentIndex === index
          onPointed: nav.currentIndex = index
          onClicked: root.activated(modelData)
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 16

      Looks.ClearText {
        Layout.fillWidth: true
        text: root.actions[nav.currentIndex]?.hint ?? ""
        elide: Text.ElideRight
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.8
        color: Settings.textColorOnContainer
      }

      KeyHints {
        keys: [["←→", "select"], ["↵", "run"], ["Esc", "close"]]
      }
    }
  }
}
