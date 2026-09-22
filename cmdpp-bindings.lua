-- yuri.cmdpp — Command++ Hyprland configuration
-- Floating window rules and global shortcut

local home = os.getenv("HOME") or ""
local wrapper = home .. "/.config/omarchy/plugins/yuri.cmdpp/bin/cmdpp-wrapper"
local launch_cmd = "setsid uwsm-app -- xdg-terminal-exec --app-id=cmdpp --title=\"Command++\" -e " .. wrapper

-- Floating window rules for Command++
o.window("cmdpp", { float = true })
o.window("cmdpp", { center = true })
-- o.window("cmdpp", { size = { 960, 600 } })

-- Keybinding: SUPER + SHIFT + H
hl.unbind("SUPER + SHIFT + H")
o.bind("SUPER + SHIFT + H", "Command++", launch_cmd)
