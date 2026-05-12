-----------------
--- AUTOSTART ---
-----------------

hl.on("hyprland.start", function ()
    -- Start shell and wallpaper
    hl.exec_cmd("qs & waypaper --restore")

    -- Start cliphist to watch text and images
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Start polkit agent (Only install one)
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Applets and background apps
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("slack --startup")
    hl.exec_cmd("discord --start-minimized")

    -- Preload Firefox
    hl.exec_cmd("[workspace 99 silent] firefox")

    -- Set cursor
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 22")
end)