import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.common.looks as Looks
import "../../common/CalendarDates.js" as Dates

// The calendar card's content: a month or a week (Settings.calendarView,
// saved as soon as it's switched), ‹ Today › in the header, the view switch
// in the footer. Its size is the card's target size; the card animates to it.
FocusScope {
  id: root

  property int weekWidth: 900
  readonly property bool weekView: Settings.calendarView === "week"
  // The month's first day, or the week's Monday.
  property date cursor: Dates.firstOfMonth(new Date())
  readonly property bool popupOpen: dayPopup.visible || eventPopup.visible

  implicitWidth: (weekView ? weekWidth - 20 : monthView.implicitWidth) + 20
  implicitHeight: content.implicitHeight + 20

  function today(): date {
    return Dates.startOfDay(new Date());
  }

  function reset(): void {
    closePopups();
    cursor = weekView ? Dates.monday(today()) : Dates.firstOfMonth(today());
    if (weekView) weekGrid.scrollToDefault();
  }

  function step(direction: int): void {
    closePopups();
    cursor = weekView ? Dates.addDays(cursor, 7 * direction) : Dates.addMonths(cursor, direction);
  }

  // Keeps to the same stretch of time: the week of `day`, the selected day,
  // today if it's in view, or else the middle of the week shown.
  function setView(view: string, day: var): void {
    closePopups();
    const now = today();
    const anchor = day ?? (weekView
      ? Dates.addDays(cursor, 3)
      : (Dates.firstOfMonth(now).getTime() === cursor.getTime() ? now : cursor));
    if (Settings.calendarView !== view) {
      Settings.calendarView = view;
      Settings.store.saveKey("calendarView");
    }
    cursor = view === "week" ? Dates.monday(anchor) : Dates.firstOfMonth(anchor);
  }

  function closePopups(): void {
    dayPopup.visible = false;
    eventPopup.visible = false;
    monthView.selectedKey = "";
  }

  function title(): string {
    if (!weekView) return Qt.formatDate(cursor, "MMMM yyyy");
    const last = Dates.addDays(cursor, 6);
    return cursor.getMonth() === last.getMonth()
      ? Qt.formatDate(cursor, "MMMM d") + " – " + last.getDate() + ", " + last.getFullYear()
      : Qt.formatDate(cursor, "MMM d") + " – " + Qt.formatDate(last, "MMM d, yyyy");
  }

  Keys.onPressed: event => {
    if (event.key === Qt.Key_Left) step(-1);
    else if (event.key === Qt.Key_Right) step(1);
    else if (event.key === Qt.Key_T) reset();
    else if (event.key === Qt.Key_M) setView("month");
    else if (event.key === Qt.Key_W) setView("week");
    else return;
    event.accepted = true;
  }

  // A click on the card's background closes a popup.
  MouseArea {
    anchors.fill: parent
    onClicked: root.closePopups()
  }

  ColumnLayout {
    id: content
    x: 10
    y: 10
    // The target width, so nothing reflows while the card animates.
    width: root.implicitWidth - 20
    spacing: 10

    CalendarHeader {
      Layout.fillWidth: true
      title: root.title()
      chip: root.weekView ? "Week " + Dates.weekNumber(root.cursor) : ""
      onPrevious: root.step(-1)
      onToday: root.reset()
      onNext: root.step(1)
    }

    MonthView {
      id: monthView
      visible: !root.weekView
      month: root.cursor
      onDayClicked: (day, cell) => {
        eventPopup.visible = false;
        if (dayPopup.visible && selectedKey === Dates.key(day)) {
          root.closePopups();
          return;
        }
        selectedKey = Dates.key(day);
        dayPopup.day = day;
        dayPopup.showFor(cell);
      }
    }

    WeekView {
      id: weekGrid
      visible: root.weekView
      contentWidth: root.weekWidth - 20
      weekStart: root.weekView ? root.cursor : Dates.monday(new Date())
      onEventClicked: (event, item) => {
        if (eventPopup.visible && eventPopup.event?.id === event.id) {
          eventPopup.visible = false;
          return;
        }
        eventPopup.event = event;
        eventPopup.showFor(item);
      }
    }

    CalendarFooter {
      Layout.fillWidth: true
      weekView: root.weekView
      onViewChosen: view => root.setView(view)
    }
  }

  DayPopup {
    id: dayPopup
    onOpenWeek: day => root.setView("week", day)
    onVisibleChanged: if (!visible) monthView.selectedKey = ""
  }

  EventPopup {
    id: eventPopup
  }
}
