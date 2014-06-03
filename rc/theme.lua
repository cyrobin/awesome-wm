-- Small modifications to anrxc's zenburn theme

local na = awful.util.color_strip_alpha
local icons = awful.util.getdir("config") .. "/icons"

--{{{ Configure according to global settings
local background_img = awful.util.getdir("config") .. "/wallpaper/background"
if config.env == "light" then
    background_img = background_img .. "-light.png"
else
    background_img = background_img .. "-dark.png"
end
--}}}

--{{{ Main -- (icons, wallpaper and font)
theme = {}
theme.icons = icons
--theme.wallpaper_cmd = { "/bin/true" }
theme.wallpaper_cmd = { "awsetbg " .. background_img }
theme.font = config.font
theme.tasklist_font = config.font
--}}}

--{{{ Main colors
-- depends on the global settings dark/light
if config.env == "light" then
    theme.bg_normal     = "#ffffffee"
    theme.bg_focus      = "#ffffff"
    theme.bg_urgent     = "#eeeeeeee"
    theme.bg_minimize   = "#bbbbbbee"

    theme.fg_normal     = "#444444"
    theme.fg_focus      = "#0066AA"
    theme.fg_urgent     = "#000000"
    theme.fg_minimize   = "#000000"

    theme.border_width  = 4
    theme.border_normal = "#FFFFFFfa"
    theme.border_focus  = "#00AA22FF"
    theme.border_marked = "#91231cf6"
else -- dark theme
    theme.bg_normal     = "#222222ee"
    theme.bg_focus      = "#222222"
    theme.bg_urgent     = "#d02e54ee"
    theme.bg_minimize   = "#444444ee"

    theme.fg_normal     = "#eeeeee"
    theme.fg_focus      = "#80ff00"
    theme.fg_urgent     = "#ffffff"
    theme.fg_minimize   = "#ffffff"

    theme.border_width  = 2
    theme.border_normal = "#000000fa"
    theme.border_focus  = "#FF7F00FF"
    theme.border_marked = "#91231cf6"
end
--}}}

--{{{ Widget stuff
if config.env == "light" then
    theme.bg_widget        = "#FFFFFFBB"
    theme.fg_widget_label  = "#939dac"
    theme.fg_widget_value  = na(theme.fg_normal)
    theme.fg_widget_value_ok  = "#009900"
    theme.fg_widget_value_warning= "#919313"
    theme.fg_widget_value_important  = "#D81F00"
    theme.fg_widget_border = theme.fg_widget_label
    theme.fg_widget_clock  = "#0066AA"
    theme.fg_widget_cmus   = "#0066AA"
else
    theme.bg_widget        = "#000000BB"
    theme.fg_widget_label  = "#939dac"
    theme.fg_widget_value  = na(theme.fg_normal)
    theme.fg_widget_value_ok  = "#80ff00"
    theme.fg_widget_value_warning= "#e1e363"
    theme.fg_widget_value_important  = "#E80F28"
    theme.fg_widget_border = theme.fg_widget_label
    theme.fg_widget_clock  = "#FF7F00"
    theme.fg_widget_cmus   = "#50d0fc"
end
--}}}

--{{{ Taglist
theme.taglist_squares_sel   = icons .. "/taglist/squarefw.png"
theme.taglist_squares_unsel = icons .. "/taglist/squarew.png"
--}}}

--{{{ Layout icons
for _, l in pairs(config.layouts) do
   theme["layout_" .. l.name] = icons .. "/layouts/" .. l.name .. ".png"
end
--}}}

--{{{ Naughty
naughty.config.presets.normal.bg = theme.bg_widget
for _,preset in pairs({"normal", "low", "critical"}) do
   naughty.config.presets[preset].font = "DejaVu Sans 10"
end
--}}}

-- {{{ Menu
-- Variables set for theming the menu:
theme.menu_height = "15"
theme.menu_width  = "100"
-- }}}

-- {{{ Other Icons
theme.awesome_icon           = icons .. "/widgets/menu.png"
theme.menu_submenu_icon      = icons .. "/widgets/submenu.png"
theme.tasklist_floating_icon = icons .. "/widgets/floatingw.png"
-- }}}

return theme
