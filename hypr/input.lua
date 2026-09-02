-----------------
----- INPUT -----
-----------------
-- kb_layout, follow_mouse, sensitivity and touchpad.natural_scroll are
-- managed by the Peridot settings app - see hypr/generated/input.lua. Edit
-- those via the settings app, not here.

hl.config({
    input = {
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})