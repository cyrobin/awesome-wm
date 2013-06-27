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
theme.font = "Terminus 8"
theme.tasklist_font = "DejaVu Sans 8"
--}}}

--{{{ Color
theme.bg_normal     = "#22222299"
theme.bg_focus      = "#d8d8d8bb"
theme.bg_urgent     = "#d02e5499"
theme.bg_minimize   = "#44444499"

theme.fg_normal     = "#cccccc"
theme.fg_normal     = "#eeeeee"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 2
theme.border_normal = "#00000000"
theme.border_focus  = "#FF7F00EE"
theme.border_marked = "#91231c66"
--}}}

--{{{ My own Color
theme.bg_focus      = "#222222"
theme.fg_focus      = "#80ff00"

theme.border_width  = 2
theme.border_normal = "#00000000"
theme.border_focus  = "#FF7F00EE"
theme.border_marked = "#91231c66"
--}}}

--{{{ Widget stuff
theme.bg_widget        = "#000000BB"
theme.fg_widget_label  = "#737d8c"
theme.fg_widget_value  = na(theme.fg_normal)
theme.fg_widget_value_important  = "#E80F28"
theme.fg_widget_border = theme.fg_widget_label
theme.fg_widget_clock  = na(theme.border_focus)
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

-- {{{ Misc
theme.awesome_icon           = "/usr/share/awesome/themes/zenburn/awesome-icon.png"
theme.menu_submenu_icon      = "/usr/share/awesome/themes/default/submenu.png"
theme.tasklist_floating_icon = "/usr/share/awesome/themes/default/tasklist/floatingw.png"
-- }}}

-- }}}
-------------------
---- {{{ Icons

---- {{{ Layout
--theme.layout_tile       = "/usr/share/awesome/themes/zenburn/layouts/tile.png"
--theme.layout_tileleft   = "/usr/share/awesome/themes/zenburn/layouts/tileleft.png"
--theme.layout_tilebottom = "/usr/share/awesome/themes/zenburn/layouts/tilebottom.png"
--theme.layout_tiletop    = "/usr/share/awesome/themes/zenburn/layouts/tiletop.png"
--theme.layout_fairv      = "/usr/share/awesome/themes/zenburn/layouts/fairv.png"
--theme.layout_fairh      = "/usr/share/awesome/themes/zenburn/layouts/fairh.png"
--theme.layout_spiral     = "/usr/share/awesome/themes/zenburn/layouts/spiral.png"
--theme.layout_dwindle    = "/usr/share/awesome/themes/zenburn/layouts/dwindle.png"
--theme.layout_max        = "/usr/share/awesome/themes/zenburn/layouts/max.png"
--theme.layout_fullscreen = "/usr/share/awesome/themes/zenburn/layouts/fullscreen.png"
--theme.layout_magnifier  = "/usr/share/awesome/themes/zenburn/layouts/magnifier.png"
--theme.layout_floating   = "/usr/share/awesome/themes/zenburn/layouts/floating.png"
---- }}}
--
---- {{{ Titlebar
--theme.titlebar_close_button_focus  = "/usr/share/awesome/themes/zenburn/titlebar/close_focus.png"
--theme.titlebar_close_button_normal = "/usr/share/awesome/themes/zenburn/titlebar/close_normal.png"
--
--theme.titlebar_ontop_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/ontop_focus_active.png"
--theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/ontop_normal_active.png"
--theme.titlebar_ontop_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/ontop_focus_inactive.png"
--theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/ontop_normal_inactive.png"
--
--theme.titlebar_sticky_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/sticky_focus_active.png"
--theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/sticky_normal_active.png"
--theme.titlebar_sticky_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/sticky_focus_inactive.png"
--theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/sticky_normal_inactive.png"
--
--theme.titlebar_floating_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/floating_focus_active.png"
--theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/floating_normal_active.png"
--theme.titlebar_floating_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/floating_focus_inactive.png"
--theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/floating_normal_inactive.png"
--
--theme.titlebar_maximized_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/maximized_focus_active.png"
--theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/maximized_normal_active.png"
--theme.titlebar_maximized_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/maximized_focus_inactive.png"
--theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/maximized_normal_inactive.png"
---- }}}
---- }}}
--
return theme
