import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.widgets
import qs.common.looks as Looks

// The view switch; in the week view also the calendars; then how the last
// sync went (click to sync now). Key hints follow on the same line in the
// week view, and on their own below the narrower month.
ColumnLayout {
  id: root

  property bool weekView: false

  signal viewChosen(string view)

  // This view's keys, and the key for the other view.
  readonly property var hints: weekView
    ? [["←→", "week"], ["T", "today"], ["M", "month"]]
    : [["←→", "month"], ["T", "today"], ["W", "week"]]

  spacing: 8

  RowLayout {
    Layout.fillWidth: true
    spacing: 12

    RadioBtnGroup {
      id: viewSwitch
      options: ["Month", "Week"]
      fontSizeModifier: 0
      onSelectionChanged: index => root.viewChosen(index === 1 ? "week" : "month")
    }

    // Not a plain binding: a click sets selectedIndex itself, which would end it,
    // and the switch would then miss changes from the M and W keys.
    Binding {
      target: viewSwitch
      property: "selectedIndex"
      value: root.weekView ? 1 : 0
    }

    Repeater {
      model: root.weekView ? CalendarService.calendars.filter(c => c.enabled !== false) : []

      delegate: RowLayout {
        id: legendItem
        required property var modelData
        spacing: 5

        Rectangle {
          implicitWidth: 8
          implicitHeight: 8
          radius: 4
          color: CalendarStyle.accent(legendItem.modelData.color)
        }

        Looks.ClearText {
          text: legendItem.modelData.name
          font.pixelSize: Looks.Fonts.size - 2
          opacity: 0.65
          color: Settings.textColorOnContainer
        }
      }
    }

    Item { Layout.fillWidth: true }

    KeyHints {
      visible: root.weekView
      keys: root.hints
    }

    Looks.ClearText {
      Layout.maximumWidth: root.weekView ? 260 : 190
      elide: Text.ElideRight
      text: (CalendarService.syncing ? "\u{f04e6}" : CalendarService.hasProblem ? "\u{f0026}" : "\u{f0450}")
        + "  " + CalendarService.statusText(Time.time)
      font.pixelSize: Looks.Fonts.size - 2
      opacity: statusArea.containsMouse ? 0.9 : 0.55
      color: Settings.textColorOnContainer

      MouseArea {
        id: statusArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: CalendarService.sync()
      }
    }
  }

  KeyHints {
    visible: !root.weekView
    keys: root.hints
  }
}
