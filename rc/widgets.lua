-- Widgets

vicious = require("vicious")
local icons = loadrc("icons", "lib/icons")
--load module for key bindings auto-doc
local keydoc = loadrc("keydoc", "lib/keydoc")

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
		    local color = beautiful.fg_widget_value_ok
		    local used = args[1]
		    if used then
			   if used > 80 then
			      color = beautiful.fg_widget_value_warning
              elseif used > 90 then
			      color = beautiful.fg_widget_value_important
			   end
		       result = string.format('<span color="' .. color .. '">%d%%</span>',
					 used)
			end
			return result
		 end, 1)
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
		       local color = beautiful.fg_widget_value_ok
		       local current = args[2]
		       local symbol = args[1]
		       if symbol == "-" then
		           symbol = "↘"
		           if current < 100 then
			          color = beautiful.fg_widget_value
			       end
		           if current < 30 then
			          color = beautiful.fg_widget_value_warning
			       end
		           if current < 10 then
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
		       elseif args[1]=="+" then
		           symbol = "↗"
		       end
		       return string.format('<span color="' .. color ..
			     '">%s%d%% (%s)</span>', symbol, current,args[3])
		    end,
	        61, "BAT0")
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
    end, 1)
--}}}

--{{{ Memory usage
local memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem,
		 function (widget, args)
		    local result = ""
		    local color = beautiful.fg_widget_value_ok
		    local used = args[1]
		    if used then
			   if used > 80 then
			      color = beautiful.fg_widget_value_warning
               elseif used > 90 then
			      color = beautiful.fg_widget_value_important
			   end
		       result = string.format('<span color="' .. color .. '">%d%%</span>',
					 used)
			end
			return result
		 end, 1)
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

--{{{ Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = config.keyboards
kbdcfg.current = 1  -- the first one is the default layout
kbdcfg.widget = widget({ type = "textbox", align = "right" })
kbdcfg.widget.text = " " .. kbdcfg.layout[kbdcfg.current] .. " "
kbdcfg.switch = function ()
   kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
   local t = " " .. kbdcfg.layout[kbdcfg.current] .. " "
   kbdcfg.widget.text = t
   t = " -layout" .. t
   os.execute( kbdcfg.cmd .. t )
end

-- Mouse bindings
kbdcfg.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () kbdcfg.switch() end)
))
--}}}

-- Create a systray
-- (especially, allows to display bluetooth and networkmanager applets)
local systray = widget({ type = "systray" })



-----------------------------------------------------------------------
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
      mylauncher,   screen.count() > 1 and sepopen,
      layoutbox[s], screen.count() > 1 and spacer,
      taglist[s],   screen.count() > 1 and sepclose,
      promptbox[s],
      layout = awful.widget.layout.horizontal.leftright
    },

    -- Date + Calendar (on all screen)
    sepclose, datewidget, spacer,
    -- Systray
    on(1, systray), on(1, spacer),
    -- Keyboard layout
    on(1, kbdcfg.widget), on(1, spacer),
    -- Volume
    on(1, volwidget), config.size == "Large" and on(1, volicon), on(1, spacer),
    -- Battery
    on(1, batwidget.widget),
    config.size == "Large" and on(1, batwidget.widget ~= "" and baticon or ""),
    on(1, batwidget.widget ~= "" and spacer or ""),
    -- File system storage
    on(1, fswidget), on(1, spacer),

    -- net graph and current state
    screen.count() > 1 and on(2, netgraph.widget),
    screen.count() > 1 and on(2, netdownicon) and on(2, netdown),
    screen.count() > 1 and on(2, netupicon) and on(2, netup) and on(2, spacer),
    -- wifi
    screen.count() > 1 and on(2, wifiwidget) and on(2, wifiicon) and on(2, sepopen),

    -- memory graph and usage
    config.size == "Large" and on(1, memgraph.widget),
    on(1, memwidget), on(1, memicon), on(1, spacer),
    -- cpu graph and usage
    config.size == "Large" and on(1, cpugraph.widget),
    on(1, cpuwidget), on(1, cpuicon), on(1, sepopen),

    -- cmus
    on(2,sepclose),on(2, cmus_widget), on(2, cmusicon), on(2, sepopen),

    -- Other
    tasklist[s],
    layout = awful.widget.layout.horizontal.rightleft }
end
--}}}
--
--{{{ key bindings for widgets
config.keys.global = awful.util.table.join(
   config.keys.global,
   keydoc.group("Widgets"),
  -- CMUS control : multimedia key bindings
   awful.key({ }, "XF86AudioPlay",        function() cmus_cmd("PlayPause") end),
   awful.key({ }, "XF86AudioPause",       function() cmus_cmd("PlayPause") end),
   awful.key({ }, "XF86AudioStop",        function() cmus_cmd("Stop") end),
   awful.key({ }, "XF86AudioNext",        function() cmus_cmd("Next") end),
   awful.key({ }, "XF86AudioPrev",        function() cmus_cmd("Previous") end),
   -- CMUS control : Without multimedia keys
   awful.key({ "Control", }, "Down", function () cmus_cmd("play_pause") end,                    "Cmus play/pause"),
   awful.key({ "Control", }, "Up", function () cmus_cmd("stop") end,                            "Cmus stop"),
   awful.key({ "Control", }, "Right", function () cmus_cmd("next") end,                         "Cmus next"),
   awful.key({ "Control", }, "Left", function () cmus_cmd("previous") end,                      "Cmus prev"),

   -- Switch the keyboard layout
   awful.key({ modkey  }, "e" , function () kbdcfg.switch() end,                                "Switch Keyboard")
   )
--}}}

--{{{ Bepo specific configuration
if config.bindings == "bepo" then

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "l", function () promptbox[mouse.screen]:run() end,                    "Prompt for a command line")
)
--}}}
--{{{ Qwerty / Azerty specific configuration
else

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end,                    "Prompt for a command line")
)
end
--}}}

config.taglist = taglist
