import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.widgets
import qs.common.looks as Looks
import "../../common/CalendarDates.js" as Dates

// A day's events, from its cell in the month view.
CalendarPopup {
  id: root

  property date day: new Date()
  readonly property string key: Dates.key(day)
  readonly property var events: CalendarService.eventsOn(day)

  signal openWeek(date day)

  // That day's part of the event.
  function timeText(event): string {
    if (event.spans) return "All day";
    const starts = event.firstDay === key;
    const ends = Dates.key(new Date(event.end)) === key;
    const start = Dates.clock(Dates.hours(new Date(event.start)));
    const end = Dates.clock(Dates.hours(new Date(event.end)));
    if (starts && ends) return start + "–" + end;
    return starts ? "from " + start : "until " + end;
  }

  Looks.ClearText {
    Layout.bottomMargin: 2
    text: Qt.formatDate(root.day, "dddd, MMMM d")
    font.pixelSize: Looks.Fonts.size + 1
    font.weight: Font.Bold
    color: Settings.textColorOnContainer
  }

  Looks.ClearText {
    visible: root.events.length === 0
    text: "No events"
    opacity: 0.6
    color: Settings.textColorOnContainer
  }

  Repeater {
    model: root.events

    delegate: RowLayout {
      id: row
      required property var modelData
      readonly property var calendar: CalendarService.calendar(modelData.cal)

      Layout.fillWidth: true
      spacing: 8

      Rectangle {
        Layout.preferredWidth: 3
        Layout.fillHeight: true
        radius: 1.5
        color: CalendarStyle.accent(row.calendar?.color ?? "blue")
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Looks.ClearText {
          Layout.fillWidth: true
          text: row.modelData.title
          elide: Text.ElideRight
          color: Settings.textColorOnContainer
        }

        Looks.ClearText {
          Layout.fillWidth: true
          text: [root.timeText(row.modelData), row.calendar?.name ?? "", row.modelData.location]
            .filter(part => part !== "").join(" · ")
          elide: Text.ElideRight
          font.pixelSize: Looks.Fonts.size - 2
          opacity: 0.6
          color: Settings.textColorOnContainer
        }
      }
    }
  }

  Button {
    Layout.topMargin: 4
    Layout.preferredHeight: Looks.Decorations.decor.elementHeight
    buttonText: "Open week " + Dates.weekNumber(root.day) + "  \u{f0142}"
    fontSizeModifier: -1
    widthPadding: 16
    onClicked: root.openWeek(root.day)
  }
}
