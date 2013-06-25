--{{{ Default requirements of awesome
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
--}}}

--{{{ Simple function to load additional LUA files from rc/.
function loadrc(name, mod)
   local success
   local result

   -- Which file? In rc/ or in lib/?
   local path = awful.util.getdir("config") .. "/" ..
      (mod and "lib" or "rc") ..
      "/" .. name .. ".lua"

   -- If the module is already loaded, don't load it again
   if mod and package.loaded[mod] then return package.loaded[mod] end

   -- Execute the RC/module file
   success, result = pcall(function() return dofile(path) end)
   if not success then
      naughty.notify({ title = "Error while loading an RC file",
		       text = "When loading `" .. name ..
			  "`, got the following error:\n" .. result,
		       preset = naughty.config.presets.critical
		     })
      return print("E: error loading RC file '" .. name .. "': " .. result)
   end

   -- Is it a module?
   if mod then
      return package.loaded[mod]
   end

   return result
end
--}}}

loadrc("errors")		-- errors and debug stuff

--{{{ Global configuration
modkey = "Mod4" -- Usually, Mod4 is the key with a logo next to Ctrl and Alt.
config = {}

config.laptop = true --enable option like battery
config.hostname = awful.util.pread('uname -n'):gsub('\n', '')

--config.terminal = "gnome-terminal"
config.terminal = "urxvtcd --perl-lib " .. awful.util.getdir("config") .. "/lib/rxvt"
config.termclass = "URxvt"
config.editor = os.getenv("EDITOR") or "vim"
config.editor_cmd = config.terminal .. " -e " .. config.editor

config.browser = "firefox"
config.mail = "thunderbird"

config.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.fair,
   awful.layout.suit.max,
   --awful.layout.suit.floating,
}
--}}}

-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

--{{{ Load remaining modules
loadrc("xrun")			-- xrun function

--loadrc("appearance")	-- theme and appearance settings
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/rc/theme.lua")

loadrc("debug")			-- debugging primitive `dbg()`

loadrc("start")			-- programs to run on start
loadrc("bindings")		-- keybindings
--loadrc("wallpaper")		-- wallpaper settings
loadrc("widgets")		-- widgets configuration
loadrc("tags")			-- tags handling
loadrc("xlock")			-- lock screen
loadrc("signals")		-- window manager behaviour
loadrc("rules")			-- window rules
loadrc("quake")			-- quake console
--loadrc("xrandr")		-- xrandr menu
--}}}

root.keys(config.keys.global)

----------- From Default rc.lua
--
---- {{{ Menu
---- Create a laucher widget and a main menu
--myawesomemenu = {
--   --{ "manual", config.terminal .. " -e man awesome" },
--   { "edit config", config.editor_cmd .. " " .. awesome.conffile },
--   { "restart", awesome.restart },
--   { "quit", awesome.quit }
--}
--
--mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
----                                    { "Debian", debian.menu.Debian_menu.Debian },
--                                    --{ "open terminal", terminal }
--                                  }
--                        })
--
--mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
--                                     menu = mymainmenu })
---- }}}
--
---- {{{ Wibox
---- Create a textclock widget
--mytextclock = awful.widget.textclock({ align = "right" })
--
---- Create a systray
--mysystray = widget({ type = "systray" })
--
---- Create a wibox for each screen and add it
--mywibox = {}
--mypromptbox = {}
--mylayoutbox = {}
--mytaglist = {}
--mytaglist.buttons = awful.util.table.join(
--                    awful.button({ }, 1, awful.tag.viewonly),
--                    awful.button({ modkey }, 1, awful.client.movetotag),
--                    awful.button({ }, 3, awful.tag.viewtoggle),
--                    awful.button({ modkey }, 3, awful.client.toggletag),
--                    awful.button({ }, 4, awful.tag.viewnext),
--                    awful.button({ }, 5, awful.tag.viewprev)
--                    )
--mytasklist = {}
--mytasklist.buttons = awful.util.table.join(
--                     awful.button({ }, 1, function (c)
--                                              if c == client.focus then
--                                                  c.minimized = true
--                                              else
--                                                  if not c:isvisible() then
--                                                      awful.tag.viewonly(c:tags()[1])
--                                                  end
--                                                  -- This will also un-minimize
--                                                  -- the client, if needed
--                                                  client.focus = c
--                                                  c:raise()
--                                              end
--                                          end),
--                     awful.button({ }, 3, function ()
--                                              if instance then
--                                                  instance:hide()
--                                                  instance = nil
--                                              else
--                                                  instance = awful.menu.clients({ width=250 })
--                                              end
--                                          end),
--                     awful.button({ }, 4, function ()
--                                              awful.client.focus.byidx(1)
--                                              if client.focus then client.focus:raise() end
--                                          end),
--                     awful.button({ }, 5, function ()
--                                              awful.client.focus.byidx(-1)
--                                              if client.focus then client.focus:raise() end
--                                          end))
--
--for s = 1, screen.count() do
--    -- Create a promptbox for each screen
--    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
--    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
--    -- We need one layoutbox per screen.
--    mylayoutbox[s] = awful.widget.layoutbox(s)
--    mylayoutbox[s]:buttons(awful.util.table.join(
--                           awful.button({ }, 1, function () awful.layout.inc(config.layouts, 1) end),
--                           awful.button({ }, 3, function () awful.layout.inc(config.layouts, -1) end),
--                           awful.button({ }, 4, function () awful.layout.inc(config.layouts, 1) end),
--                           awful.button({ }, 5, function () awful.layout.inc(config.layouts, -1) end)))
--    -- Create a taglist widget
--    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
--
--    -- Create a tasklist widget
--    mytasklist[s] = awful.widget.tasklist(function(c)
--                                              return awful.widget.tasklist.label.currenttags(c, s)
--                                          end, mytasklist.buttons)
--
--    -- Create the wibox
--    mywibox[s] = awful.wibox({ position = "top", screen = s })
--    -- Add widgets to the wibox - order matters
--    mywibox[s].widgets = {
--        {
--            mylauncher,
--            mytaglist[s],
--            mypromptbox[s],
--            layout = awful.widget.layout.horizontal.leftright
--        },
--        mylayoutbox[s],
--        mytextclock,
--        s == 1 and mysystray or nil,
--        mytasklist[s],
--        layout = awful.widget.layout.horizontal.rightleft
--    }
--end
---- }}}
--
