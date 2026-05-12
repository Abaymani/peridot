-------------------
--- KEYBINDINGS ---
-------------------

local terminal = "kitty"
local fileManager = "nautilus"
local browser = "firefox"
local editor = "code"
local mainMod = "SUPER"
local peridot_scripts = os.getenv("HOME") .. "/.config/peridot/scripts"

hl.config({
    binds = {
        workspace_back_and_forth = true
    }
})

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager .. " --new-window"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + section", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized"}))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Quickshell
hl.bind(mainMod .. " + A", hl.dsp.global("quickshell:toggleControlCenter"))
hl.bind(mainMod .. " + V", hl.dsp.global("quickshell:toggleClipboard"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Resize window
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))

-- Workspace prev/next
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- Cycle window (Old `binde` translates to the `repeating = true` flag)
hl.bind("ALT + Tab", hl.dsp.window.cycle_next(), { repeating = true })

-- Custom scripts
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(peridot_scripts .. "/screenshot.sh"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging (Old `bindm`)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/peridot/peridot/scripts/changeBrightness.sh -u 200000 -A 10"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/peridot/peridot/scripts/changeBrightness.sh -u 200000 -U 10"), { repeating = true, locked = true })

-- Requires playerctl
-- Old `bindl` (locked) translates to `{ locked = true }`
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Change wallpaper
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("waypaper --random"))