import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.common.looks as Looks
import "../../common/CalendarDates.js" as Dates

// One event's details, beside its block in the week view.
CalendarPopup {
  id: root

  property var event: null
  readonly property var calendar: event ? CalendarService.calendar(event.cal) : null

  beside: true
  cardWidth: 290

  function whenText(): string {
    if (!event) return "";
    const start = new Date(event.start);
    const end = new Date(event.end);
    if (event.allDay) {
      const last = Dates.fromKey(event.lastDay);
      return event.firstDay === event.lastDay
        ? Qt.formatDate(start, "dddd, MMMM d")
        : Qt.formatDate(start, "MMM d") + " – " + Qt.formatDate(last, "MMM d");
    }
    if (Dates.key(start) === Dates.key(end) || (event.lastDay === event.firstDay))
      return Qt.formatDate(start, "ddd, MMM d") + " · " + Dates.clock(Dates.hours(start)) + "–" + Dates.clock(Dates.hours(end));
    return Qt.formatDate(start, "ddd, MMM d") + " " + Dates.clock(Dates.hours(start))
      + " – " + Qt.formatDate(end, "ddd, MMM d") + " " + Dates.clock(Dates.hours(end));
  }

  // Google writes some descriptions as HTML.
  function plain(text: string): string {
    return text.replace(/<br\s*\/?>/gi, "\n").replace(/<[^>]+>/g, "")
      .replace(/&nbsp;/g, " ").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").trim();
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: 8

    Rectangle {
      Layout.alignment: Qt.AlignTop
      Layout.topMargin: 4
      Layout.preferredWidth: 10
      Layout.preferredHeight: 10
      radius: 3
      color: CalendarStyle.accent(root.calendar?.color ?? "blue")
    }

    Looks.ClearText {
      Layout.fillWidth: true
      text: root.event?.title ?? ""
      wrapMode: Text.Wrap
      font.pixelSize: Looks.Fonts.size + 2
      font.weight: Font.Bold
      color: Settings.textColorOnContainer
    }
  }

  Repeater {
    model: [
      ["\u{f0954}", root.whenText()],
      ["\u{f034e}", root.event?.location ?? ""],
      ["\u{f00ed}", root.calendar?.name ?? ""]
    ].filter(row => row[1] !== "")

    delegate: RowLayout {
      required property var modelData
      Layout.fillWidth: true
      spacing: 8

      Looks.ClearText {
        Layout.alignment: Qt.AlignTop
        Layout.preferredWidth: 14
        text: modelData[0]
        opacity: 0.7
        color: Settings.textColorOnContainer
      }

      Looks.ClearText {
        Layout.fillWidth: true
        text: modelData[1]
        wrapMode: Text.Wrap
        font.pixelSize: Looks.Fonts.size - 1
        color: Settings.textColorOnContainer
      }
    }
  }

  Looks.ClearText {
    Layout.fillWidth: true
    Layout.topMargin: 4
    visible: text !== ""
    text: root.plain(root.event?.description ?? "")
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    maximumLineCount: 8
    elide: Text.ElideRight
    font.pixelSize: Looks.Fonts.size - 1
    opacity: 0.75
    color: Settings.textColorOnContainer
  }
}
