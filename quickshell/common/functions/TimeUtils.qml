pragma Singleton
import Quickshell

Singleton{
  function formatRelativeTime(past, now) {
    const timestamp = past.getTime();
    const diffMs = now.getTime() - timestamp;
    const diffMins = Math.floor(diffMs / 60000);

    console.log(timestamp)
    if (diffMins < 1) return "now";
    if (diffMins < 60) return diffMins + "m";
    if (diffMins < 1440) return Math.floor(diffMins / 60) + "h";

    const days = Math.floor(diffMins / 1440);
    return days === 1 ? "1 day" : days + " days";
  }
}