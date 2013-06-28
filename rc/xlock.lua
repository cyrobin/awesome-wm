--{{{ Configure according to global settings
-- The background screensaver image must be a png file for i3lock
local screenSaver = awful.util.getdir("config") .. "/wallpaper/background"
if config.env == "light" then
    screenSaver = screenSaver .. "-light.png"
else
    screenSaver = screenSaver .. "-dark.png"
end
--}}}

--{{{ lock on demand
config.keys.global = awful.util.table.join(
   config.keys.global,
   --awful.key({}, "XF86ScreenSaver", function() awful.util.spawn("xautolock -locknow", false) end))
   awful.key({}, "XF86ScreenSaver", 
        function() awful.util.spawn("i3lock -n -i " .. screenSaver .. " -t", false) end))

config.keys.global = awful.util.table.join(
   config.keys.global,
   --awful.key({ modkey, }, "BackSpace", function() awful.util.spawn("xautolock -locknow", false) end))
   awful.key({ modkey, }, "BackSpace", 
        function() awful.util.spawn("i3lock -n -i " .. screenSaver .. " -t", false) end))
---}}}
