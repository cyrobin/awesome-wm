-- Handle brightness (with xbacklight)

local awful        = require("awful")
local naughty      = require("naughty")
local tonumber     = tonumber
local string       = string
local os           = os

-- A bit odd, but...
require("lib/icons")
local icons        = package.loaded["lib/icons"]

module("lib/brightness")

local nid = nil
local function change(what)
   -- Actually,
   -- We don't really change the brightness, just report the change...
   -- and the value does not fit to the display..
   -- TODO : FIXIT
   -- Set the change
   os.execute("xbacklight " .. what, false)
   -- Get the current value
   local out = awful.util.pread("xbacklight -get")
   -- use instead:
   -- xrandr -q | grep " connected" 
   -- (get the first argument of each line)
   -- xrandr --output LVDS1 --brightness 0.5
   --
   --  voir aussi cat /sys/class/backlight/acpi_video0/max_brightness" 
   --  "echo 5 > /sys/class/backlight/acpi_video0/brightness"
   --  (et chanher les droits sur les fichiers)

   if not out then return end

   out = tonumber(out)
  local icon = icons.lookup({name = "display-brightness",
                  type = "status"})

  nid = naughty.notify({ text = string.format("%3d %%", out),
              icon = icon,
              font = "Free Sans Bold 24",
              replaces_id = nid }).id
end

function increase()
   change("-inc 5")
end

function decrease()
   change("-dec 5")
end
