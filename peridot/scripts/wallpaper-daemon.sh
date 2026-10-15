#!/usr/bin/env bash
# Starts the wallpaper daemon at login, alongside the shell rather than after
# it. Uses the backend chosen on the shell's

settings="$HOME/.config/peridot/settings/settings.json"
backend=$(jq -r '.wallpaperBackend // "awww"' "$settings" 2>/dev/null)

case "$backend" in
    awww | swww) ;;
    *) backend=awww ;;
esac

"$backend" query >/dev/null 2>&1 || exec "$backend-daemon"
