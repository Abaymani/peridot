#!/bin/bash
# Installs peridot-sddm as the SDDM greeter theme.

set -e

THEME_NAME="peridot-sddm"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v sddm &>/dev/null && ! command -v sddm-greeter-qt6 &>/dev/null; then
    echo "SDDM isn't installed, nothing to do."
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "Needs root. Using sudo..."
    exec sudo bash "$SCRIPT_DIR/install.sh" "$@"
fi

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
USER_HOME=$(eval echo "~$TARGET_USER")

echo "Installing theme to $THEME_DIR..."
mkdir -p "$THEME_DIR/Components" "$THEME_DIR/Backgrounds"
cp "$SCRIPT_DIR"/Main.qml "$THEME_DIR/"
cp "$SCRIPT_DIR"/metadata.desktop "$THEME_DIR/"
cp "$SCRIPT_DIR"/theme.conf "$THEME_DIR/"
cp "$SCRIPT_DIR"/colors.json "$THEME_DIR/"
cp "$SCRIPT_DIR"/Components/*.qml "$THEME_DIR/Components/"
cp "$SCRIPT_DIR"/Backgrounds/* "$THEME_DIR/Backgrounds/" 2>/dev/null
chmod -R a+rX "$THEME_DIR"

# The theme reads colors.json/decor.json and current_wallpaper.txt straight
# from the user's peridot checkout via the ~/.config/{quickshell,peridot}
# symlinks. Those files are already world-readable (matugen writes them
# 644) - the only thing blocking sddm is that $HOME and $HOME/.config are
# 700, so it can't even traverse into them. Grant just enough to pass
# through: execute-only, no read/list, on exactly those two directories.
if command -v setfacl &>/dev/null; then
    echo "Granting sddm traversal into $USER_HOME..."
    setfacl -m u:sddm:--x "$USER_HOME"
    setfacl -m u:sddm:--x "$USER_HOME/.config"
    echo "Done."
else
    echo "setfacl not found (package: acl) - install it and re-run this script"
    echo "for live colors/wallpaper. The theme will fall back to its bundled"
    echo "colors.json and Backgrounds/pond_shed.png until then."
fi

SDDM_CONF="/etc/sddm.conf.d/$THEME_NAME.conf"
mkdir -p /etc/sddm.conf.d
echo "Configuring SDDM..."
cat > "$SDDM_CONF" <<EOF
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1

[Theme]
Current=$THEME_NAME
EOF

if [ -f /etc/sddm.conf ] && grep -q '^\s*Current=' /etc/sddm.conf; then
    sed -i "s/^\(\s*\)Current=.*/\1Current=$THEME_NAME/" /etc/sddm.conf
fi

echo ""
echo "Installed. Preview any time without logging out:"
echo "  sddm-greeter-qt6 --test-mode --theme $THEME_DIR"
echo "Restart SDDM to use it as the real login screen:"
echo "  sudo systemctl restart sddm"
