-- Lockscreen
local icons = loadrc("icons", "lib/icons")

-- The background screensaver image must be a png file for i3lock
local screenSaver = awful.util.getdir("config") .. "/wallpaper/background.png"

--{{{ autolock the screen when there is no activity
xrun("xautolock",
     awful.util.getdir("config") ..
        "/bin/xautolock " ..
        icons.lookup({name = "system-lock-screen", type = "actions" }))
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
--
-- Configure DPMS
--os.execute("xset dpms 360 720 1200")
