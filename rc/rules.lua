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

   --{{{ Browser stuff
   { rule = { role = "browser" },
     callback = function(c)
	 if not c.icon then
	    local icon = icons.lookup({ name = "web-browser", type = "apps" })
	    if icon then c.icon = image(icon) end
	 end
     end },
   --}}}
   --{{{ All windows should be slaves, except the browser windows.
   { rule_any = { class = { "Iceweasel", "Firefox", "Chromium", "Conkeror", "Google-chrome", "Opera" } },
     callback = function(c)
	    if c.role ~= "browser" then awful.client.setslave(c) end
     end },
    --}}}
   --{{{ Plugin
   { rule = { instance = "plugin-container" },
     properties = { floating = true }}, -- Flash with Firefox
   { rule = { instance = "exe", class="Exe", instance="exe" },
     properties = { floating = true }}, -- Flash with Chromium
   --}}}

   --{{{ Mail client stuff
   { rule = { role = "mail" },
     callback = function(c)
	 if not c.icon then
	    local icon = icons.lookup({ name = "mail-client", type = "apps" })
	    if icon then c.icon = image(icon) end
	 end
     callback = awful.client.setslave
     end },
   --}}}

}
