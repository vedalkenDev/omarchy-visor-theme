-- Visor shape: 10px corners, no blur or shadow, opaque terminals.
-- A theme installed from GitHub can't ship Lua, so extras/shape.sh copies this
-- into Omarchy's Hyprland toggles folder, which loads after the theme.
hl.config({
  decoration = {
    rounding = 10,
    rounding_power = 2,
    shadow = { enabled = false },
    blur = { enabled = false },
  },
})

o.transparent_window({ tag = "terminal" }, "1 1")
