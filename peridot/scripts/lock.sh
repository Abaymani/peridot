#!/bin/bash
# Locks the screen with hyprlock, and tells the shell while it's up so the
# on-screen keyboard can offer itself above the lock (see

pidof hyprlock >/dev/null && exit 0

qs ipc call lock locked >/dev/null 2>&1
hyprlock "$@"
qs ipc call lock unlocked >/dev/null 2>&1
