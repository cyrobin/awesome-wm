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
