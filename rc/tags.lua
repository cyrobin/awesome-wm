-- Tags

local shifty = loadrc("shifty", "lib/shifty")
local keydoc = loadrc("keydoc", "lib/keydoc")

local tagicon = function(icon) --{{{
   return beautiful.icons .. "/taglist/" .. icon .. ".png"
end--}}}

shifty.config.tags = { --{{{
   xterm = {
      position = 1,
      --layout = awful.layout.suit.fair,
      layout = awful.layout.suit.tile,
      mwfact = 0.6,
      exclusive = true,
      slave = true,
      screen = 1,
      spawn = config.terminal,
      icon = tagicon("dev"),
   },
   www = {
      position = 2,
      layout = awful.layout.suit.tile.bottom,
      mwfact = 0.7,
      exclusive = true,
      max_clients = 1,
      screen = math.max(screen.count(), 2),
      spawn = config.browser,
      icon = tagicon("web")
   },
   mail = {
      position = 3,
      layout = awful.layout.suit.tile.top,
      mwfact = 0.7,
      exclusive = true,
      screen = math.max(screen.count(), 2),
      spawn = config.mail,
      slave= true,
      icon = tagicon("im")
   },
   chat = {
      position = 3,
      layout = awful.layout.suit.tile.left,
      mwfact = 0.7,
      --exclusive = true,
      screen = math.max(screen.count(), 2),
      --spawn = config.chat,
      slave= true,
      icon = tagicon("im")
   },
   viewer = {
      position = 5,
      layout = awful.layout.suit.max,
      mwfact = 0.7,
      exclusive = true,
      max_clients = 1,
      screen = math.max(screen.count(), 2),
      slave=true,
      --spawn = config.player,
      --icon = tagicon("viewer"),
   },
   misc = {
      position = 7,
      layout = awful.layout.suit.floating,
      --mwfact = 0.6,
      slave = true,
      screen = math.max(screen.count(), 2),
      icon = tagicon("dev"),
   },
   media = {
      position = 8,
      layout = awful.layout.suit.max,
      mwfact = 0.6,
      exclusive = true,
      max_clients = 1,
      screen = math.max(screen.count(), 2),
      spawn = config.player,
      icon = tagicon("music"),
      --nopopup = true,           -- don't give focus on creation
   },
   download = {
      position = 9,
      layout = awful.layout.suit.tile,
      mwfact = 0.6,
      exclusive = true,
      screen = 1,
      spawn = "transmission-gtk",
      --icon = tagicon("download"),
      nopopup = true,           -- don't give focus on creation
   },
}--}}}

-- Also, see rules.lua
shifty.config.apps = {--{{{
   {
      match = { "Firefox","Chromium-browser","Opera","Uzbl" },
      tag = "www",
   },
   {
      --match = { role = { "mail", "conversation", "buddy_list" } },
      match = { "Thunderbird", "mutt", "Geary", "Evolution", "Icedove" },
      tag = "mail",
   },
   {
      match = { "pidgin","Buddy List", "buddy_list" },
      tag = "chat",
   },
   {
      match = { config.termclass },
      startup = {
         tag = "xterm"
      },
      intrusive = true,         -- Display even on exclusive tags
   },
   {
      match = { "mendeleydesktop", "evince" },
      tag = "viewer",
   },
   {
      match = { "vlc", "Blender" },
      tag = "media",
   },
   {
      match = {
        --class = {config.termclass,},
      name = {"cmus .",}},
      tag = "media",
      slave = false,
   },
   {
      match = { "transmission-gtk", "Transmission" },
      tag = "download",
   },
}--}}}

shifty.config.defaults = {--{{{
   layout = config.layouts[1],
   mwfact = 0.6,
   ncol = 1,
   sweep_delay = 1,
}--}}}

shifty.taglist = config.taglist -- Set in widget.lua
shifty.init()

-- Global keys configuration
config.keys.global = awful.util.table.join(
   --{{{ General tags navigation
   config.keys.global,
   keydoc.group("Tag management"),
   awful.key({ modkey }, "Escape", awful.tag.history.restore, "Switch to previous tag"),
   awful.key({ modkey }, "Left", awful.tag.viewprev),
   awful.key({ modkey }, "Right", awful.tag.viewnext),
   awful.key({ modkey, "Shift"}, "o",
             function()
                if screen.count() == 1 then return nil end
                local t = awful.tag.selected()
                local s = awful.util.cycle(screen.count(), t.screen + 1)
                awful.tag.history.restore()
                t = shifty.tagtoscr(s, t)
                awful.tag.viewonly(t)
             end,
             "Send tag to next screen"),
   awful.key({ modkey, "Control", "Shift"}, "o",
             function()
                if screen.count() == 1 then return nil end
                local t = awful.tag.selected()
                local o = t.screen
                local s = awful.util.cycle(screen.count(), o + 1)
                for _, t in pairs(screen[o]:tags()) do
                   shifty.tagtoscr(s, t)
                end
             end,
             "Send all tags to next screen"),
   awful.key({ modkey }, "n", shifty.add, "Create a new tag"),
   awful.key({ modkey, "Shift" }, "n", shifty.del, "Delete tag"),
   awful.key({ modkey, "Control" }, "n", shifty.rename, "Rename tag"))
--}}}

--{{{ Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, (shifty.config.maxtags or 9) do
   config.keys.global = awful.util.table.join(
      config.keys.global,
      keydoc.group("Tag management"),
      awful.key({ modkey }, "#" .. i + 9,
                function ()
                   local t = shifty.getpos(i)
                   local s = t.screen
                   local c = awful.client.focus.history.get(s, 0)
                   awful.tag.viewonly(t)
                   mouse.screen = s
                   if c then client.focus = c end
                end,
                i == 5 and "Display only this tag" or nil), -- i==5 -> display once
      awful.key({ modkey, "Control" }, "#" .. i + 9,
                function ()
                   local t = shifty.getpos(i)
                   t.selected = not t.selected
                end,
                i == 5 and "Toggle display of this tag" or nil), -- i==5 -> display once
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function ()
                   local c = client.focus
                   if c then
                      local t = shifty.getpos(i)
                      awful.client.movetotag(t, c)
                   end
                end,
                i == 5 and "Move window to this tag" or nil), -- i==5 -> display once
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                function ()
                   if client.focus then
                      awful.client.toggletag(shifty.getpos(i))
                   end
                end,
                i == 5 and "Toggle this tag on this window" or nil), -- i==5 -> display once
      keydoc.group("Misc"))
end
--}}}
