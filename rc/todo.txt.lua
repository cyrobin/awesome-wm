local todo = loadrc("todo.txt", "lib/todo.txt")

local todoconsole = {}
for s = 1, screen.count() do
   todoconsole[s] = todo({ terminal = config.terminal,
			     width = 0.35,
			     screen = s })
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   --awful.key({ modkey }, "t",
   awful.key({ modkey }, "d",
	     function () todoconsole[mouse.screen]:toggle() end,
	     "Toggle ToDo console"))
