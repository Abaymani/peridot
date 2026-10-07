pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.common.functions
import "../common/CalendarDates.js" as Dates

// Calendars from iCal URLs (e.g. Google Calendar's secret addresses), set in
// Preferences › Calendar. peridot/scripts/calendar-sync.py fetches them into a
// cache, which this indexes by day for the calendar popup.
Singleton {
  id: root

  // The color slots matugen makes: cal_<slot>, cal_<slot>_container and
  // on_cal_<slot>_container in Colors.md3 (see matugen/config.toml).
  readonly property var slots: ["blue", "green", "purple", "amber", "teal", "red"]

  // [{ id, name, url, color, enabled }]
  property alias calendars: jsonAdapter.calendars
  property alias refreshMinutes: jsonAdapter.refreshMinutes

  // The URLs give read access to the calendars, so this file stays out of git.
  readonly property SettingsStore store: SettingsStore {
    path: Quickshell.env("HOME") + "/.config/peridot/settings/calendars.json"

    JsonAdapter {
      id: jsonAdapter

      property var calendars: []
      property int refreshMinutes: 5
    }
  }

  readonly property string cachePath: Quickshell.env("HOME") + "/.config/peridot/.cache/calendar.json"
  readonly property string script: Quickshell.env("HOME") + "/.config/peridot/scripts/calendar-sync.py"

  // The last sync's report: { synced, error, calendars: { <id>: { ok, error, synced, count } } }.
  property var report: ({})
  // Events by day key, all-day ones first, then by start; see index().
  property var days: ({})
  readonly property bool syncing: syncProcess.running
  property double lastSyncStarted: 0
  property bool syncAgain: false

  function calendar(id: string): var {
    return calendars.find(c => c.id === id) ?? null;
  }

  // Off calendars are hidden straight away, before a sync drops their events.
  function shown(id: string): bool {
    const entry = calendar(id);
    return entry !== null && entry.enabled !== false;
  }

  function colorOf(id: string): string {
    return calendar(id)?.color ?? slots[0];
  }

  function eventsOn(day: date): var {
    return (days[Dates.key(day)] ?? []).filter(event => shown(event.cal));
  }

  // One dot per calendar with events that day, in calendar order.
  function colorsOn(day: date): var {
    const ids = eventsOn(day).map(event => event.cal);
    return calendars.filter(c => ids.includes(c.id)).map(c => c.color);
  }

  // The first color no calendar uses yet.
  function nextColor(): string {
    const used = calendars.map(c => c.color);
    return slots.find(slot => !used.includes(slot)) ?? slots[calendars.length % slots.length];
  }

  function sync(): void {
    if (syncProcess.running) {
      syncAgain = true;
      return;
    }
    lastSyncStarted = Date.now();
    syncProcess.running = true;
  }

  // On opening the calendar; the timer covers the rest.
  function syncIfStale(): void {
    if (Date.now() - lastSyncStarted > 60000) sync();
  }

  // Calendars that are on and have a URL.
  readonly property var activeCalendars: calendars.filter(c => c.enabled !== false && (c.url ?? "").trim() !== "")
  readonly property bool hasProblem: !!report.error || activeCalendars.some(c => report.calendars?.[c.id]?.ok === false)

  // A line for the calendar's footer.
  function statusText(now: date): string {
    const active = activeCalendars;
    if (active.length === 0) return "Add calendars in Settings";
    if (report.error) return report.error;
    if (syncing && !report.synced) return "Syncing…";
    const failed = active.find(c => report.calendars?.[c.id]?.ok === false);
    if (failed) return failed.name + ": " + report.calendars[failed.id].error;
    if (syncing) return "Syncing…";
    if (!report.synced) return "Not synced yet";
    const ago = TimeUtils.formatRelativeTime(new Date(report.synced), now);
    return ago === "now" ? "Synced just now" : "Synced " + ago + " ago";
  }

  function load(text: string): void {
    let data;
    try {
      data = JSON.parse(text);
    } catch (e) {
      return;
    }
    report = { synced: data.synced ?? "", error: data.error ?? "", calendars: data.calendars ?? {} };
    days = index(data.events ?? []);
  }

  // Puts each event under every day it touches. Times are kept as ms, so the
  // events survive being copied into Repeater models. Timed events of a day
  // or more count as spanning, so the week view draws them with all-day ones.
  function index(events: var): var {
    const result = {};
    let id = 0;
    for (const raw of events) {
      const start = raw.allDay ? Dates.fromKey(raw.start) : Dates.fromLocal(raw.start);
      const end = raw.allDay ? Dates.fromKey(raw.end) : Dates.fromLocal(raw.end);
      // All-day ends are exclusive, and a timed event ending at midnight
      // doesn't touch that day.
      const lastDay = raw.allDay || (end > start && Dates.hours(end) === 0)
        ? Dates.addDays(end, -1)
        : Dates.startOfDay(end);
      const event = {
        id: id++,
        cal: raw.cal,
        title: raw.title,
        location: raw.location ?? "",
        description: raw.description ?? "",
        allDay: raw.allDay,
        spans: raw.allDay || end - start >= 86400000,
        start: start.getTime(),
        end: end.getTime(),
        firstDay: Dates.key(start),
        lastDay: Dates.key(lastDay)
      };
      for (let day = Dates.startOfDay(start); day <= lastDay; day = Dates.addDays(day, 1)) {
        const key = Dates.key(day);
        if (!result[key]) result[key] = [];
        result[key].push(event);
      }
    }
    for (const key in result)
      result[key].sort((a, b) => (b.spans - a.spans) || (a.start - b.start) || (b.end - a.end));
    return result;
  }

  Process {
    id: syncProcess
    command: ["python3", root.script, root.store.path, root.cachePath]
    stderr: StdioCollector { id: syncErrors }

    onExited: (exitCode, exitStatus) => {
      // 1 is a reported problem (in the cache); anything else is a crash.
      if (exitCode > 1) console.warn("calendar-sync.py failed:", syncErrors.text);
      // The watch misses the cache's first write: there was no file to watch.
      cache.reload();
      if (root.syncAgain) {
        root.syncAgain = false;
        root.sync();
      }
    }
  }

  FileView {
    id: cache
    path: root.cachePath
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.load(text())
  }

  Connections {
    target: root.store

    function onSaved(): void {
      root.sync();
    }
  }

  Timer {
    interval: Math.max(1, root.refreshMinutes) * 60000
    running: true
    repeat: true
    onTriggered: root.sync()
  }

  // Catches up after a suspend: a tick that comes late means time went by unseen.
  Timer {
    property double lastTick: Date.now()

    interval: 30000
    running: true
    repeat: true
    onTriggered: {
      const now = Date.now();
      if (now - lastTick > 90000) root.sync();
      lastTick = now;
    }
  }

  Component.onCompleted: sync()
}
