import QtQuick
import Quickshell
import qs
import qs.services
import qs.widgets
import qs.common.looks as Looks
import qs.programs.calendar

// The calendar, opened from the bar's clock (see ClockWidget) and placed
// under it on that clock's screen. The card animates between the month's
// size and the week's; Escape or a click outside closes a popup first, then
// the calendar. A click on the bar, the clock included, closes it all.
Scope {
  id: root

  OverlayPanel {
    id: panel

    readonly property int gap: 8
    readonly property real barBottom: Looks.Decorations.decor.barMarginTop + Looks.Decorations.decor.barHeight
    readonly property real screenWidth: screen?.width ?? 1920
    // Off while opening, so the card starts at its size instead of growing.
    property bool animate: false
    property real shownWidth: view.implicitWidth
    property real shownHeight: view.implicitHeight

    Behavior on shownWidth {
      enabled: panel.animate
      NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    Behavior on shownHeight {
      enabled: panel.animate
      NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    open: GlobalStates.isCalendarOpen
    screen: Quickshell.screens.find(s => s.name === GlobalStates.calendarScreen) ?? null
    // Over the bar too. While the calendar has the keyboard, Hyprland sends
    // clicks only to it, so the clock can't hear a second click; this way
    // the click lands here and closes the calendar.
    exclusionMode: ExclusionMode.Ignore
    cardWidth: shownWidth
    cardHeight: shownHeight
    // Centred under the clock, kept on screen.
    cardPosition: {
      const center = GlobalStates.calendarAnchorX >= 0 ? GlobalStates.calendarAnchorX : screenWidth / 2;
      return Qt.point(Math.max(gap, Math.min(center - shownWidth / 2, screenWidth - gap - shownWidth)), barBottom + gap);
    }

    onOpened: {
      animate = false;
      view.reset();
      view.forceActiveFocus();
      CalendarService.syncIfStale();
      Qt.callLater(() => panel.animate = true);
    }

    onDismissed: {
      const onBar = dismissPoint.y >= 0 && dismissPoint.y < barBottom;
      if (view.popupOpen && !onBar) view.closePopups();
      else GlobalStates.isCalendarOpen = false;
    }

    onVisibleChanged: if (!visible) view.closePopups()

    CalendarView {
      id: view
      width: implicitWidth
      height: implicitHeight
      focus: true
      weekWidth: Math.min(900, panel.screenWidth - 2 * panel.gap)
    }
  }
}
