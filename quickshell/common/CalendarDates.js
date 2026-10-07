.pragma library

// Dates for the calendar. Weeks start on Monday and are numbered the Swedish
// way (ISO 8601: week 1 is the week with the year's first Thursday). Days are
// keyed "yyyy-MM-dd" in local time.

function pad(n) {
  return (n < 10 ? "0" : "") + n
}

function key(date) {
  return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate())
}

function fromKey(text) {
  const parts = text.split("-")
  return new Date(+parts[0], +parts[1] - 1, +parts[2])
}

// "yyyy-MM-ddTHH:mm", as calendar-sync.py writes local times.
function fromLocal(text) {
  const day = fromKey(text.slice(0, 10))
  day.setHours(+text.slice(11, 13), +text.slice(14, 16))
  return day
}

function addDays(date, days) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() + days)
}

function startOfDay(date) {
  return addDays(date, 0)
}

function monday(date) {
  return addDays(date, -((date.getDay() + 6) % 7))
}

function firstOfMonth(date) {
  return new Date(date.getFullYear(), date.getMonth(), 1)
}

function addMonths(date, months) {
  return new Date(date.getFullYear(), date.getMonth() + months, 1)
}

function weekNumber(date) {
  const day = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
  // The Thursday of this week decides the year it belongs to.
  day.setUTCDate(day.getUTCDate() + 4 - (day.getUTCDay() || 7))
  const yearStart = new Date(Date.UTC(day.getUTCFullYear(), 0, 1))
  return Math.ceil(((day - yearStart) / 86400000 + 1) / 7)
}

// Whole days from a to b, ignoring DST (both at local midnight).
function daysBetween(a, b) {
  return Math.round((startOfDay(b) - startOfDay(a)) / 86400000)
}

function hours(date) {
  return date.getHours() + date.getMinutes() / 60
}

// 13.25 -> "13:15"
function clock(hourValue) {
  const minutes = Math.round(hourValue * 60)
  return pad(Math.floor(minutes / 60) % 24) + ":" + pad(minutes % 60)
}

// The rows of a month grid: each a Monday and its week number.
function monthWeeks(month) {
  const first = firstOfMonth(month)
  const daysInMonth = new Date(first.getFullYear(), first.getMonth() + 1, 0).getDate()
  const rows = Math.ceil(((first.getDay() + 6) % 7 + daysInMonth) / 7)
  const weeks = []
  for (let row = 0; row < rows; row++) {
    const start = addDays(monday(first), row * 7)
    weeks.push({ start: start, number: weekNumber(start) })
  }
  return weeks
}
