#!/bin/bash
# Locks the screen with hyprlock, and tells the shell while it's up so the
# on-screen keyboard can offer itself above the lock (see
# quickshell/programs/OnScreenKeyboard.qml).

# Closing the lid locks from the lid bind and hypridle at the same moment, so
# only one copy gets past here. `pidof` alone races: every copy starts its own
# hyprlock, Hyprland refuses all but the first, and the refused ones hang
# forever, so later locks think the screen is already locked.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/peridot-lock.lock"
flock -n 9 || exit 0
pidof hyprlock >/dev/null && exit 0

qs ipc call lock locked >/dev/null 2>&1
hyprlock "$@"
qs ipc call lock unlocked >/dev/null 2>&1
