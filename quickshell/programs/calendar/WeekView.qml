import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.widgets
import qs.common.looks as Looks
import "../../common/CalendarDates.js" as Dates

// A week like Google Calendar's: days as columns, all 24 hours as scrolling
// rows, and all-day (or longer) events as bars across the top.
ColumnLayout {
  id: root

  property date weekStart: Dates.monday(new Date())
  property int contentWidth: 860
  property int hourHeight: 36
  property int visibleHours: 13

  signal eventClicked(var event, Item item)

  readonly property int gutter: 48
  readonly property real columnWidth: (contentWidth - gutter) / 7
  readonly property var days: [0, 1, 2, 3, 4, 5, 6].map(i => Dates.addDays(weekStart, i))
  readonly property int todayIndex: days.findIndex(day => Dates.key(day) === Dates.key(Time.time))
  readonly property var perDay: days.map(day => CalendarService.eventsOn(day))
  readonly property var bars: layoutBars()
  readonly property int lanes: bars.reduce((count, bar) => Math.max(count, bar.lane + 1), 0)
  readonly property var blocks: layoutBlocks()

  spacing: 0

  // Opens with 08:00 at the top, a little above the line so its label shows.
  function scrollToDefault(): void {
    grid.contentY = Math.max(0, Math.min(8 * hourHeight - 10, grid.contentHeight - grid.height));
  }

  function timeText(event): string {
    return Dates.clock(Dates.hours(new Date(event.start))) + "–" + Dates.clock(Dates.hours(new Date(event.end)));
  }

  // Each spanning event once, as columns c0..c1 of this week, stacked in lanes.
  function layoutBars(): var {
    const seen = {};
    const laneEnds = [];
    const result = [];
    for (const events of perDay) {
      for (const event of events) {
        if (!event.spans || seen[event.id]) continue;
        seen[event.id] = true;
        const c0 = Math.max(0, Dates.daysBetween(weekStart, Dates.fromKey(event.firstDay)));
        const c1 = Math.min(6, Dates.daysBetween(weekStart, Dates.fromKey(event.lastDay)));
        let lane = laneEnds.findIndex(end => end < c0);
        if (lane < 0) {
          lane = laneEnds.length;
          laneEnds.push(0);
        }
        laneEnds[lane] = c1;
        result.push({ event: event, c0: c0, c1: c1, lane: lane });
      }
    }
    return result;
  }

  // Each day's part of the timed events, in hours, side by side where they
  // overlap (cols is how many share the cluster, col which one this is).
  function layoutBlocks(): var {
    const result = [];
    perDay.forEach((events, dayIndex) => {
      const key = Dates.key(days[dayIndex]);
      const parts = events.filter(event => !event.spans).map(event => {
        const end = new Date(event.end);
        const from = event.firstDay === key ? Dates.hours(new Date(event.start)) : 0;
        // Runs to midnight unless it ends this day.
        const to = Dates.key(end) === key ? Dates.hours(end) : 24;
        return { event: event, day: dayIndex, from: from, to: Math.max(to, from + 0.25) };
      });
      parts.sort((a, b) => a.from - b.from || b.to - a.to);
      let cluster = [];
      let clusterEnd = -1;
      const close = () => {
        const columns = [];
        for (const part of cluster) {
          let col = columns.findIndex(end => end <= part.from);
          if (col < 0) {
            col = columns.length;
            columns.push(0);
          }
          columns[col] = part.to;
          part.col = col;
        }
        for (const part of cluster) {
          part.cols = columns.length;
          result.push(part);
        }
        cluster = [];
      };
      for (const part of parts) {
        if (part.from >= clusterEnd && cluster.length > 0) close();
        cluster.push(part);
        clusterEnd = Math.max(clusterEnd, part.to);
      }
      if (cluster.length > 0) close();
    });
    return result;
  }

  // Day names and dates.
  Item {
    Layout.preferredWidth: root.contentWidth
    Layout.preferredHeight: 46

    Repeater {
      model: 7

      delegate: Item {
        id: dayHead
        required property int index
        readonly property bool isToday: index === root.todayIndex

        x: root.gutter + index * root.columnWidth
        width: root.columnWidth
        height: parent.height

        Looks.ClearText {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.locale().dayName((dayHead.index + 1) % 7, Locale.ShortFormat)
          font.pixelSize: Looks.Fonts.size - 2
          font.weight: Font.Bold
          font.letterSpacing: 1
          font.capitalization: Font.AllUppercase
          opacity: 0.55
          color: Settings.textColorOnContainer
        }

        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          y: 15
          width: 28
          height: 28
          radius: 14
          color: dayHead.isToday ? Looks.Colors.md3.primary : "transparent"

          Looks.ClearText {
            anchors.centerIn: parent
            text: root.days[dayHead.index].getDate()
            font.pixelSize: Looks.Fonts.size + 4
            font.weight: dayHead.isToday ? Font.Bold : Looks.Fonts.weight
            color: dayHead.isToday ? Looks.Colors.md3.on_primary : Settings.textColorOnContainer
          }
        }
      }
    }
  }

  // All-day strip.
  Item {
    Layout.preferredWidth: root.contentWidth
    Layout.preferredHeight: Math.max(1, root.lanes) * 22 + 6

    Rectangle { width: parent.width; height: 1; color: CalendarStyle.line }
    Rectangle { y: parent.height - 1; width: parent.width; height: 1; color: CalendarStyle.line }

    Looks.ClearText {
      y: 6
      width: root.gutter - 8
      horizontalAlignment: Text.AlignRight
      text: "all-day"
      font.pixelSize: Looks.Fonts.size - 3
      opacity: 0.55
      color: Settings.textColorOnContainer
    }

    Repeater {
      model: root.bars

      delegate: EventChip {
        id: bar
        required property var modelData
        x: root.gutter + modelData.c0 * root.columnWidth + 2
        y: 4 + modelData.lane * 22
        width: (modelData.c1 - modelData.c0 + 1) * root.columnWidth - 4
        height: 19
        slot: CalendarService.colorOf(modelData.event.cal)
        title: modelData.event.title
        onClicked: root.eventClicked(bar.modelData.event, bar)
      }
    }
  }

  // Hours.
  Item {
    Layout.preferredWidth: root.contentWidth
    Layout.preferredHeight: root.visibleHours * root.hourHeight

    Flickable {
      id: grid
      anchors.fill: parent
      contentWidth: width
      contentHeight: 24 * root.hourHeight
      boundsBehavior: Flickable.StopAtBounds
      clip: true

      Repeater {
        model: 24

        delegate: Item {
          required property int index
          y: index * root.hourHeight
          width: grid.width

          Rectangle {
            x: root.gutter
            width: parent.width - root.gutter
            height: 1
            color: CalendarStyle.line
          }

          Looks.ClearText {
            visible: index > 0
            y: -7
            width: root.gutter - 8
            horizontalAlignment: Text.AlignRight
            text: Dates.pad(index) + ":00"
            font.pixelSize: Looks.Fonts.size - 2
            opacity: 0.55
            color: Settings.textColorOnContainer
          }
        }
      }

      Repeater {
        model: 7

        delegate: Rectangle {
          required property int index
          x: root.gutter + index * root.columnWidth
          width: 1
          height: grid.contentHeight
          color: CalendarStyle.line
        }
      }

      Repeater {
        model: root.blocks

        delegate: EventChip {
          id: block
          required property var modelData
          readonly property real slotWidth: (root.columnWidth - 4) / modelData.cols

          x: root.gutter + modelData.day * root.columnWidth + 2 + modelData.col * slotWidth
          y: modelData.from * root.hourHeight + 1
          width: slotWidth - 2
          height: Math.max(16, (modelData.to - modelData.from) * root.hourHeight - 2)
          slot: CalendarService.colorOf(modelData.event.cal)
          title: modelData.event.title
          time: root.timeText(modelData.event)
          onClicked: root.eventClicked(block.modelData.event, block)
        }
      }

      // Now.
      Item {
        visible: root.todayIndex >= 0
        x: root.gutter + root.todayIndex * root.columnWidth
        y: Dates.hours(Time.time) * root.hourHeight
        width: root.columnWidth

        Rectangle { y: -1; width: parent.width; height: 2; color: Looks.Colors.md3.primary }
        Rectangle { x: -4; y: -4; width: 8; height: 8; radius: 4; color: Looks.Colors.md3.primary }
      }
    }

    FastScrollArea {
      anchors.fill: parent
      target: grid
    }
  }

  onWeekStartChanged: Qt.callLater(scrollToDefault)
  Component.onCompleted: Qt.callLater(scrollToDefault)
}
