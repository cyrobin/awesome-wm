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

}
