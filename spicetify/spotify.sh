#!/bin/sh
# Starts Spotify via spotify-launcher. An update replaces the patched app files,
# so Spicetify is re-applied before launching whenever they're stock again.

spotify-launcher --no-exec

if [ -e "$HOME/.local/share/spotify-launcher/install/usr/share/spotify/Apps/xpui.spa" ]; then
    spicetify -q backup apply -n
fi

exec spotify-launcher --skip-update "$@"
