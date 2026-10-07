#!/usr/bin/env python3
"""Fetches the calendars set in Preferences › Calendar and writes their events
for the shell's calendar (quickshell/services/Calendar.qml).

    calendar-sync.py <calendars.json> <cache.json>

Each enabled calendar's iCal URL (e.g. Google Calendar's "Secret address in
iCal format") is fetched, repeating events are expanded over a window around
today, and times are converted to local time. A calendar that fails keeps the
events it had in the cache, with the error beside it.

Needs python-icalendar and python-recurring-ical-events.
"""

import json
import os
import sys
import tempfile
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from datetime import date, datetime, time, timedelta

MONTHS_BACK = 12
MONTHS_AHEAD = 18
TIMEOUT = 20
MAX_DESCRIPTION = 2000


def now_iso():
    return datetime.now().strftime("%Y-%m-%dT%H:%M:%S")


def load_json(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, ValueError):
        return default


# Written beside the target and renamed over it, so the shell never reads half a file.
def write_json(path, data):
    folder = os.path.dirname(path) or "."
    os.makedirs(folder, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=folder, prefix=".calendar-", suffix=".json")
    with os.fdopen(fd, "w") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    os.replace(tmp, path)


def add_months(day, months):
    m = day.month - 1 + months
    return day.replace(year=day.year + m // 12, month=m % 12 + 1, day=1)


def fetch(url):
    if url.startswith("webcal://"):
        url = "https://" + url[len("webcal://"):]
    request = urllib.request.Request(url, headers={"User-Agent": "peridot-calendar"})
    with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
        return response.read()


def text(component, name, limit=None):
    value = component.get(name)
    if value is None:
        return ""
    value = str(value).strip()
    return value[:limit] if limit else value


# Times with a zone go to the system's zone, with the DST of that instant;
# floating times are local already.
def local(moment):
    if moment.tzinfo is not None:
        moment = moment.astimezone()
    return moment.strftime("%Y-%m-%dT%H:%M")


def convert(event, calendar_id):
    if text(event, "STATUS").upper() == "CANCELLED" or event.get("DTSTART") is None:
        return None

    start = event.get("DTSTART").dt
    end = event.get("DTEND").dt if event.get("DTEND") is not None else None
    if end is None and event.get("DURATION") is not None:
        end = start + event.get("DURATION").dt

    result = {
        "cal": calendar_id,
        "title": text(event, "SUMMARY") or "(No title)",
        "location": text(event, "LOCATION"),
        "description": text(event, "DESCRIPTION", MAX_DESCRIPTION),
    }

    if not isinstance(start, datetime):
        # All day; the end date is exclusive, as in iCal.
        if end is None or isinstance(end, datetime) or end <= start:
            end = start + timedelta(days=1)
        result.update(allDay=True, start=start.isoformat(), end=end.isoformat())
    else:
        if end is None:
            end = start
        elif not isinstance(end, datetime):
            end = datetime.combine(end, time(), start.tzinfo)
        result.update(allDay=False, start=local(start), end=local(max(end, start)))
    return result


def sync_calendar(calendar, start, end):
    import icalendar
    import recurring_ical_events
    import x_wr_timezone

    try:
        data = fetch(str(calendar["url"]).strip())
    except urllib.error.HTTPError as e:
        return {"error": f"The server answered {e.code}. Check the URL."}
    except ValueError:
        return {"error": "That isn't a web address."}
    except (urllib.error.URLError, OSError):
        return {"error": "Couldn't reach the calendar."}

    try:
        feed = x_wr_timezone.to_standard(icalendar.Calendar.from_ical(data))
        occurrences = recurring_ical_events.of(feed).between(start, end)
    except Exception:
        return {"error": "That address doesn't give an iCal calendar."}

    events = []
    for occurrence in occurrences:
        try:
            event = convert(occurrence, calendar["id"])
        except (TypeError, ValueError, AttributeError):
            continue  # One malformed event shouldn't cost the rest.
        if event is not None:
            events.append(event)
    return {"events": events}


def main():
    if len(sys.argv) != 3:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    settings_path, cache_path = sys.argv[1:]

    settings = load_json(settings_path, {})
    calendars = [c for c in settings.get("calendars", [])
                 if isinstance(c, dict) and c.get("id") and c.get("enabled", True)]
    old = load_json(cache_path, {})
    old_events = old.get("events", [])
    old_status = old.get("calendars", {})

    result = {"version": 1, "synced": now_iso(), "error": "", "calendars": {}, "events": []}

    def keep_old(calendar, error):
        kept = [e for e in old_events if e.get("cal") == calendar["id"]]
        result["events"].extend(kept)
        previous = old_status.get(calendar["id"], {})
        result["calendars"][calendar["id"]] = {
            "ok": False, "error": error, "synced": previous.get("synced", ""), "count": len(kept)}

    try:
        import icalendar  # noqa: F401
        import recurring_ical_events  # noqa: F401
        import x_wr_timezone  # noqa: F401
    except ImportError:
        result["error"] = "Install python-icalendar and python-recurring-ical-events to sync calendars."
        for calendar in calendars:
            keep_old(calendar, result["error"])
        write_json(cache_path, result)
        return 1

    today = date.today().replace(day=1)
    start, end = add_months(today, -MONTHS_BACK), add_months(today, MONTHS_AHEAD + 1)

    with_url = [c for c in calendars if str(c.get("url", "")).strip()]
    with ThreadPoolExecutor(max_workers=max(1, min(8, len(with_url)))) as pool:
        synced = list(pool.map(lambda c: sync_calendar(c, start, end), with_url))

    for calendar, outcome in zip(with_url, synced):
        if "error" in outcome:
            keep_old(calendar, outcome["error"])
            continue
        result["events"].extend(outcome["events"])
        result["calendars"][calendar["id"]] = {
            "ok": True, "error": "", "synced": now_iso(), "count": len(outcome["events"])}

    result["events"].sort(key=lambda e: (e["start"], e["end"]))
    write_json(cache_path, result)
    return 0


if __name__ == "__main__":
    sys.exit(main())
