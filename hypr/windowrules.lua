--------------------------------
----- WINDOWS & LAYERRULES -----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
    --Ignore maximize requests from all apps. You'll probably like this.
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    -- Hyprland-run windowrule
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})


hl.window_rule({
    -- Pavucontrol
    name = "pavu-rule",
    size = { 800, 600 },
    float =  true,
    center = true,
    match = { class = "org.pulseaudio.pavucontrol" },
})

hl.window_rule({
    -- Blueman gloating
    name = "blueman-rule",
    size = { 700, 600 },
    float =  true,
    center = true,
    match = { class = "blueman-manager" },
})

hl.window_rule({
    -- Waypaper floating
    name = "waypaper-rule",
    size = { 900, 900 },
    float = true,
    center = true,
    match = { class = "waypaper" },
})

hl.window_rule({
    -- Nwg-look floating
    name = "nwg-rule",
    size = { 800, 600 },
    float = true,
    center = true,
    match = { class = "nwg-look" },
})

hl.window_rule({
    -- General floating class
    name = "Peridot-float",
    size = { 900, 900 },
    float = true,
    center = true,
    match = { class = "peridot-floating" },
})

hl.window_rule({
    -- NetworkManager connections editor
    name = "nm-connections-rule",
    size = { 400, 600 },
    float = true,
    center = true,
    match = { class = "nm-connection-editor" },
})

---- LAYERRULES ----
hl.layer_rule({
    blur = true,
    ignore_alpha = 0,
    match = { namespace = "quickshell"},
})

hl.layer_rule({
    blur = true,
    ignore_alpha = 0.4,
    match = { namespace = "logout_dialog"},
})