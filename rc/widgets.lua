-- Widgets

vicious = require("vicious")
local icons = loadrc("icons", "lib/icons")

--{{{ Separators
local sepopen = widget({ type = "imagebox" })
sepopen.image = image(beautiful.icons .. "/widgets/left.png")
local sepclose = widget({ type = "imagebox" })
sepclose.image = image(beautiful.icons .. "/widgets/right.png")
local spacer = widget({ type = "imagebox" })
spacer.image = image(beautiful.icons .. "/widgets/spacer.png")
--}}}

--{{{ Date (includes a calendar)
local datewidget = widget({ type = "textbox" })
local dateformat = "%a %d/%m, %H:%M"
vicious.register(datewidget, vicious.widgets.date,
		 '<span color="' .. beautiful.fg_widget_clock .. '">' ..
		    dateformat .. '</span>', 61)
local cal = (
   function()
      local calendar = nil
      local offset = 0

      local remove_calendar = function()
	 if calendar ~= nil then
	    naughty.destroy(calendar)
	    calendar = nil
	    offset = 0
	 end
      end

      local add_calendar = function(inc_offset)
	 local save_offset = offset
	 remove_calendar()
	 offset = save_offset + inc_offset
	 local datespec = os.date("*t")
	 datespec = datespec.year * 12 + datespec.month - 1 + offset
	 datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
	 local cal = awful.util.pread("ncal -w -m " .. datespec)
	 -- Highlight the current date and month
	 cal = cal:gsub("_.([%d ])",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_clock))
	 cal = cal:gsub("^( +[^ ]+ [0-9]+) *",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_clock))
	 -- Turn anything other than days in labels
	 cal = cal:gsub("(\n[^%d ]+)",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_label))
	 cal = cal:gsub("([%d ]+)\n?$",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_label))
	 calendar = naughty.notify(
	    {
	       text = string.format('<span font="%s">%s</span>',
				    "Terminus 8",
				    cal:gsub(" +\n","\n")),
	       timeout = 0, hover_timeout = 0.5,
	       width = 160,
	       screen = mouse.screen,
	    })
      end

      return { add = add_calendar,
	       rem = remove_calendar }
   end)()

datewidget:add_signal("mouse::enter", function() cal.add(0) end)
datewidget:add_signal("mouse::leave", cal.rem)
datewidget:buttons(awful.util.table.join(
		      awful.button({ }, 3, function() cal.add(-1) end),
		      awful.button({ }, 1, function() cal.add(1) end),
		      awful.button({ }, 4, function() cal.add(-1) end),
		      awful.button({ }, 5, function() cal.add(1) end)))
--}}}

--{{{ CPU usage
local cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu,
		 function (widget, args)
		    local result = ""
		    local color = beautiful.fg_widget_value
		    local used = args[1]
		    if used then
			   if used > 90 then
			      color = beautiful.fg_widget_value_important
			   end
		       result = string.format('<span color="' .. color .. '">%d%%</span>',
					 used)
			end
			return result
		 end, 3)
local cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.icons .. "/widgets/cpu.png")
-- CPU Graph
cpugraph = awful.widget.graph()
-- Graph properties
cpugraph:set_width(40):set_height(16)
cpugraph:set_border_color(beautiful.fg_widget_border)
cpugraph:set_background_color("#000000")
cpugraph:set_color("#30BB77")
-- Register widget
vicious.register(cpugraph, vicious.widgets.cpu, "$1")
--}}}

--{{{ Battery
local batwidget = { widget = "" }
if config.laptop then
   batwidget.widget = widget({ type = "textbox" })
   vicious.register(batwidget.widget, vicious.widgets.bat,
		    function (widget, args)
		       local color = beautiful.fg_widget_value
		       local current = args[2]
		       if current < 20 and args[1] == "-" then
			     color = beautiful.fg_widget_warning
			   end
		       if current < 10 and args[1] == "-" then
			     color = beautiful.fg_widget_value_important
			     -- Maybe we want to display a small warning?
			     if current ~= batwidget.lastwarn then
			        batwidget.lastid = naughty.notify(
			       { title = "Battery low!",
			         preset = naughty.config.presets.critical,
			         timeout = 20,
			         text = "Battery level is currently " ..
			            current .. "%.\n" .. args[3] ..
			            " left before running out of power.",
			         icon = icons.lookup({name = "battery-caution",
			       		       type = "status"}),
			         replaces_id = batwidget.lastid }).id
			        batwidget.lastwarn = current
			     end
		       end
		       return string.format('<span color="' .. color ..
			     '">%s%d%% (%s)</span>', args[1], current,args[3])
		    end,
	        60, "BAT0")
end
local baticon = widget({ type = "imagebox" })
baticon.image = image(beautiful.icons .. "/widgets/bat.png")
--}}}

--{{{ Network
local netup   = widget({ type = "textbox" })
local netdown = widget({ type = "textbox" })
local netupicon = widget({ type = "imagebox" })
netupicon.image = image(beautiful.icons .. "/widgets/up.png")
local netdownicon = widget({ type = "imagebox" })
netdownicon.image = image(beautiful.icons .. "/widgets/down.png")

local netgraph = awful.widget.graph()
netgraph:set_width(80):set_height(16)
netgraph:set_stack(true):set_scale(true)
netgraph:set_border_color(beautiful.fg_widget_border)
netgraph:set_stack_colors({ "#EF8171", "#cfefb3" })
netgraph:set_background_color("#00000033")
vicious.register(netup, vicious.widgets.net,
    function (widget, args)
       -- We sum up/down value for all interfaces
       local up = 0
       local down = 0
       local iface
       for name, value in pairs(args) do
	  iface = name:match("^{(%S+) down_b}$")
	  if iface and iface ~= "lo" then down = down + value end
	  iface = name:match("^{(%S+) up_b}$")
	  if iface and iface ~= "lo" then up = up + value end
       end
       -- Update the graph
       netgraph:add_value(up, 1)
       netgraph:add_value(down, 2)
       -- Format the string representation
       local format = function(val)
	  if val > 500000 then
	     return string.format("%.1f MB", val/1000000.)
	  elseif val > 500 then
	     return string.format("%.1f KB", val/1000.)
	  end
	  return string.format("%d B", val)
       end
       -- Down
       netdown.text = string.format('<span color="' .. beautiful.fg_widget_value ..
				    '">%08s</span>', format(down))
       -- Up
       return string.format('<span color="' .. beautiful.fg_widget_value ..
			    '">%08s</span>', format(up))
    end, 3)
--}}}

--{{{ Memory usage
local memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem,
		 function (widget, args)
		    local result = ""
		    local color = beautiful.fg_widget_value
		    local used = args[1]
		    if used then
			   if used > 90 then
			      color = beautiful.fg_widget_value_important
			   end
		       result = string.format('<span color="' .. color .. '">%d%%</span>',
					 used)
			end
			return result
		 end, 3)
		 --'<span color="' .. beautiful.fg_widget_value .. '">$1%</span>',
		 --1)
local memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.icons .. "/widgets/mem.png")
-- Memory Graph
memgraph = awful.widget.graph()
-- Graph properties
memgraph:set_width(40):set_height(16)
memgraph:set_border_color(beautiful.fg_widget_border)
memgraph:set_background_color("#000000")
memgraph:set_color("#77BBCC")
-- Register widget
vicious.register(memgraph, vicious.widgets.mem, "$1")
--}}}

--{{{ Volume level
local volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.icons .. "/widgets/vol.png")
local volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume,
		 function (widget, args)
		    local result = ""
		    local color = beautiful.fg_widget_value
		    local used = args[1]
		    if used then
			   if used == 0 then
			      color = beautiful.fg_widget_value_important
			   end
		       result = string.format(
			        '<span color="' .. beautiful.fg_widget_value .. '">%s </span>' ..
                    '<span color="' .. color .. '">%d%%</span>',
					 args[2],used)
			end
			return result
         end,
		17, "Master")
volume = loadrc("volume", "lib/volume")
volwidget:buttons(awful.util.table.join(
		     awful.button({ }, 1, volume.mixer),
		     awful.button({ }, 3, volume.toggle),
		     awful.button({ }, 4, volume.increase),
		     awful.button({ }, 5, volume.decrease)))
--}}}

--{{{ File systems
local fs = { "/",
	     "/home",
	     "/var",
	     "/usr",
	     "/tmp"}
--local fsicon = widget({ type = "imagebox" })
--fsicon.image = image(beautiful.icons .. "/widgets/disk.png")
local fswidget = widget({ type = "textbox" })
vicious.register(fswidget, vicious.widgets.fs,
		 function (widget, args)
		    local result = ""
		    for _, path in pairs(fs) do
		       local used = args["{" .. path .. " used_p}"]
		       local color = beautiful.fg_widget_value
		       if used then
			      if used > 90 then
			         color = beautiful.fg_widget_value_important
			      end
                  local name = string.gsub(path, "[%w/]*/(%w+)", "%1")
                  if name == "/" then name = "root" end
			      result = string.format(
			        '%s%s<span color="' .. beautiful.fg_widget_label .. '">%s: </span>' ..
				    '<span color="' .. color .. '">%2d%%</span>',
			      result, #result > 0 and " " or "", name, used)
		       end
		    end
		    return result
		 end, 53)
--}}}

--{{{ Applications menu
-- largely based on awesome freedesktop (git submodule)
require('freedesktop/freedesktop.utils')
freedesktop.utils.terminal = config.terminal
freedesktop.utils.icon_theme = {'mate','Mint-X-Dark','gnome'} -- look inside /usr/share/icons/, default: nil (don't use icon theme)
require('freedesktop/freedesktop.menu')
local debianMenu = loadrc("debian-menu") -- Load the debian menu

menu_items = freedesktop.menu.new()
myawesomemenu = {
   { "manual", config.terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
   { "edit config", config.editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
   { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
   { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
}
table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "open terminal", config.terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })
table.insert(menu_items, { "Debian", debian.menu.Debian_menu.Debian, freedesktop.utils.lookup_icon({ icon = 'debian-logo' }) })

mymainmenu = awful.menu.new({ items = menu_items, width = 150 })

mylauncher = awful.widget.launcher({ 
        image = image(beautiful.icons .. "/widgets/menu.png"),
        menu = mymainmenu })

--}}}

--{{{ Wifi
local iwlist = loadrc("iwlist", "lib/iwlist")

local wifiwidget = widget({ type = "textbox" })
local wifiicon = widget({ type = "imagebox" })
wifiicon.image = image(beautiful.icons .. "/widgets/wifi.png")

local wifitooltip= awful.tooltip({})
wifitooltip:add_to_object(wifiwidget)

vicious.register(wifiwidget, vicious.widgets.wifi, 
    function(widget, args)
        local tooltip = ("<b>mode</b> %s <b>chan</b> %s <b>rate</b> %s Mb/s"):format(
                        args["{mode}"], args["{chan}"], args["{rate}"])
        local quality = 0
        if args["{linp}"] > 0 then
          quality = args["{link}"] / args["{linp}"] * 100
        end
        wifitooltip:set_text(tooltip)
        return ("%s: %.1f%%"):format(args["{ssid}"], quality)
    end, 
    7, "wlan0")

wifiicon:buttons( wifiwidget:buttons(awful.util.table.join(
    awful.button({}, 1,  -- left click
    function()
        local networks = iwlist.scan_networks()
        if #networks > 0 then
          local msg = {}
          for i, ap in ipairs(networks) do
            local line = "<b>ESSID:</b> %s <b>MAC:</b> %s <b>Qual.:</b> %.2f%% <b>%s</b>"
            local enc = iwlist.get_encryption(ap)
            msg[i] = line:format(ap.essid, ap.address, ap.quality, enc)
          end
          naughty.notify({text = table.concat(msg, "\n")})
        else
        end
    end),
    awful.button({ "Shift" }, 1,  -- left click
    function ()
    -- restart-auto-wireless is just a script of mine,
    -- which just restart netcfg
    -- TODO : change this
    --    local wpa_cmd = "sudo restart-auto-wireless && notify-send 'wpa_actiond' 'restarted' || notify-send 'wpa_actiond' 'error on restart'"
    --    awful.util.spawn_with_shell(wpa_cmd)
    end),
    awful.button({ }, 3,  -- right click
    function ()  
        vicious.force{wifiwidget} 
    end)
    )))
--}}}

--{{{ Cmus - music player
--local cmus =  loadrc("cmus", "lib/cmus")
loadrc("cmus")
cmus_widget = widget({ type = "textbox", align = "right" })
-- refresh Cmus widget
cmus_timer = timer({timeout = 1})
cmus_timer:add_signal("timeout", function() cmus_widget.text = ' ' .. hook_cmus() .. ' ' end)
cmus_timer:start()
--}}}

-- Create a systray
-- (especially, allows to display bluetooth and networkmanager applets)
local systray = widget({ type = "systray" })

--{{{ Wibox initialisation
local wibox     = {}
local promptbox = {}
local layoutbox = {}

local taglist = {}
taglist.buttons = awful.util.table.join(
                  awful.button({ }, 1, awful.tag.viewonly),
                  awful.button({ }, 3, awful.tag.viewtoggle),
                  awful.button({ modkey }, 3, awful.client.toggletag)
                  )
local tasklist = {}
tasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
		   if c == client.focus then
		      c.minimized = true
		   else
		      if not c:isvisible() then
			 awful.tag.viewonly(c:tags()[1])
		      end
		      -- This will also un-minimize the client, if needed
		      client.focus = c
		      c:raise()
		   end
		end),
   awful.button({ }, 3, function ()
            if instance then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({ width=250 })
            end
        end))

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    layoutbox[s] = awful.widget.layoutbox(s)
    tasklist[s]  = awful.widget.tasklist(
       function(c)
	  local title, color, _, icon = awful.widget.tasklist.label.currenttags(c, s)
	  return title, color, nil, icon
       end, tasklist.buttons)

    -- Create the taglist
    taglist[s] = awful.widget.taglist.new(s,
            awful.widget.taglist.label.all, taglist.buttons)
    -- Create the wibox
    wibox[s] = awful.wibox({ screen = s,
			     fg = beautiful.fg_normal,
			     bg = beautiful.bg_widget,
			     position = "top",
			     height = 16,
    })
    -- Add widgets to the wibox -- n if the chosen screen
    local on = function(n, what)
       if s == n or n > screen.count() then return what end
       return ""
    end

    wibox[s].widgets = {
        {
       mylauncher,
	   screen.count() > 1 and sepopen or "",
	   layoutbox[s],
	   screen.count() > 1 and spacer or "",
	   taglist[s],
	   screen.count() > 1 and sepclose or "",
	   promptbox[s],
	   layout = awful.widget.layout.horizontal.leftright
	},
	-- Systray
	on(1, systray),
	-- Date + Calendar
	sepclose, datewidget, spacer,
	-- Volume
	on(2, volwidget), screen.count() > 1 and on(2, volicon) or "", on(2, spacer),
    -- Battery
	on(2, batwidget.widget),
	on(2, batwidget.widget ~= "" and baticon or ""),
	on(2, batwidget.widget ~= "" and spacer or ""),
    -- File system storage
	on(2, fswidget),
    -- net graph -- not displayed if only one screen
	screen.count() > 1 and on(2, sepopen) or on(2, spacer),
	screen.count() > 1 and on(1, netgraph.widget) or "",
    -- net current stat
	on(1, netdownicon), on(1, netdown),
	on(1, netupicon), on(1, netup), on(1, spacer),
	-- wifi
	on(1, wifiwidget), on(1, wifiicon), on(1, spacer),
    -- mem graph -- not displayed if only one screen
	screen.count() > 1 and on(2, sepopen) or on(2, spacer),
	screen.count() > 1 and on(1, memgraph.widget) or "",
    -- memory usage
	on(1, memwidget), on(1, memicon), on(1, spacer),
    -- cpu graph -- not displayed if only one screen
	screen.count() > 1 and on(2, sepopen) or on(2, spacer),
	screen.count() > 1 and on(1, cpugraph.widget) or "",
	-- cpu usage
	on(1, cpuwidget), on(1, cpuicon), on(1, sepopen),
--	-- cmus
    on(2,sepclose),on(2, cmus_widget), on(2, cmusicon), on(2, sepopen),
	-- Other
	tasklist[s],
	layout = awful.widget.layout.horizontal.rightleft }
end
--}}}

--{{{ key bindings for widgets
config.keys.global = awful.util.table.join(
   config.keys.global,
   -- Promt a command line
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end,
	     "Prompt for a command"),
   -- CMUS control : multimedia key bindings
   awful.key({ }, "XF86AudioPlay",        function() cmus_cmd("PlayPause") end),
   awful.key({ }, "XF86AudioPause",       function() cmus_cmd("PlayPause") end),
   awful.key({ }, "XF86AudioStop",        function() cmus_cmd("Stop") end),
   awful.key({ }, "XF86AudioNext",        function() cmus_cmd("Next") end),
   awful.key({ }, "XF86AudioPrev",        function() cmus_cmd("Previous") end),
   -- CMUS control : Without multimedia keys
   awful.key({ "Control", }, "Right", function () cmus_cmd("next") end),
   awful.key({ "Control", }, "Left", function () cmus_cmd("previous") end),
   awful.key({ "Control", }, "Up", function () cmus_cmd("stop") end),
   awful.key({ "Control", }, "Down", function () cmus_cmd("play_pause") end)
   )
--}}}

config.taglist = taglist
