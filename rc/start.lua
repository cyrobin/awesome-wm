--{{{ Setup display
local xrandr = {
   aallallaas = "--output HDMI-0 --auto --output DVI-0 --auto --right-of HDMI-0"
}
if xrandr[config.hostname] then
   os.execute("xrandr " .. xrandr[config.hostname])
end
--}}}

-- Spawn a compositing manager
awful.util.spawn("xcompmgr", false)

--{{{ Start idempotent commands
local execute = {
   -- Start PulseAudio
   "pulseaudio --check || pulseaudio -D",
   "xset -b",	-- Disable bell
   -- Enable numlock
   "numlockx on",
   -- Read resources
   --"xrdb -merge " .. awful.util.getdir("config") .. "/Xresources",
   -- Default browser
   "xdg-mime default " .. config.browser .. ".desktop x-scheme-handler/http",
   "xdg-mime default " .. config.browser .. ".desktop x-scheme-handler/https",
   "xdg-mime default " .. config.browser .. ".desktop text/html"
}
--}}}

--{{{ Keyboard/Mouse configuration
if config.hostname == "alfred-laas" then
   execute = awful.util.table.join(
      execute, {
     -- Mouse acceleration
	 "xset m 3 3",
	 -- Keyboards set up and toggle
	 "setxkbmap fr,us '' compose:rwin ctrl:nocaps grp:rctrl_rshift_toggle",
	 --"xmodmap -e 'keysym Pause = XF86ScreenSaver'",
	       })
end
--}}}
--
os.execute(table.concat(execute, ";"))

--{{{ Spawn various X programs
xrun("polkit-gnome-authentication-agent-1",
     "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
xrun("Bluetooth Applet",
     "bluetooth-applet")
--xrun("pidgin", "pidgin -n")
xrun("nm-applet", "pkill nm-applet ; nm-applet")
-- TODO : Dropbox

if config.hostname == "alfred-laas" then
   xrun("NetworkManager Applet", "nm-applet")
end
--}}}