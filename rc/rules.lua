local icons = loadrc("icons", "lib/icons")

awful.rules.rules = {
   --{{{ All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = true,
        maximized_vertical   = false,
        maximized_horizontal = false,
        keys = config.keys.client,
        buttons = config.mouse.client }},
   --}}}
   -- YouTube fullscreen mode in Firefox (1st) and Chromium (2nd)
    { rule = { instance = "plugin-container" },
      properties = {floating = true }},
    { rule = { instance = "exe" },
      properties = {floating = true }},
}
