-- CMUS controler, taken from Robin Hahling
-- http://blog.rolinh.ch/linux/un-widget-controleur-pour-le-lecteur-audio-cmus-pour-awesome-wm/

--module("lib/cmus")

--{{{ Get cmus PID to check if it is running
function getCmusPid()
  local fpid = io.popen("pgrep cmus")
  local pid = fpid:read("*n")
  fpid:close()
  return pid
end--}}}

--{{{ Enable cmus control
function cmus_cmd (action)
  local cmus_info, cmus_state
  local cmus_run = getCmusPid()
  if cmus_run then
      cmus_info = io.popen("cmus-remote -Q"):read("*all")
      cmus_state = string.gsub(string.match(cmus_info, "status %a*"),"status ","")
      if cmus_state ~= "stopped" then
          if action == "next" then
              io.popen("cmus-remote -n")
          elseif action == "previous" then
              io.popen("cmus-remote -r")
          elseif action == "stop" then
              io.popen("cmus-remote -s")
          end
      end
      if action == "play_pause" then
          if cmus_state == "playing" or cmus_state == "paused" then
              io.popen("cmus-remote -u")
          elseif cmus_state == "stopped" then
              io.popen("cmus-remote -p")
          end
      end
  end
end--}}}

-- Cmus Widget
function hook_cmus() --{{{
  -- check if cmus is running
  local cmus_run = getCmusPid()
  if cmus_run then
      cmus_info = io.popen("cmus-remote -Q"):read("*all")
      cmus_state = string.gsub(string.match(cmus_info, "status %a*"),"status ","")
      if cmus_state == "playing" or cmus_state == "paused" then
          cmus_artist = string.gsub(string.match(cmus_info, "tag artist %C*"), "tag artist ","")
          cmus_title = string.gsub(string.match(cmus_info, "tag title %C*"), "tag title ","")
          cmus_curtime = string.gsub(string.match(cmus_info, "position %d*"), "position ","")
          cmus_curtime_formated = math.floor(cmus_curtime/60) .. ':' .. string.format("%02d",cmus_curtime % 60)
          cmus_totaltime = string.gsub(string.match(cmus_info, "duration %d*"), "duration ","")
          cmus_totaltime_formated = math.floor(cmus_totaltime/60) .. ':' .. string.format("%02d",cmus_totaltime % 60)
          if cmus_artist == "" then
              cmus_artist = "unknown artist"
          end
          if cmus_title == "" then
              cmus_title = "unknown title"
          end
          -- cmus_title = string.format("%.5c", cmus_title)
          cmus_string = cmus_artist .. " - " .. cmus_title .. " (" .. cmus_curtime_formated .. "/" .. cmus_totaltime_formated .. ")"
          if cmus_state == "paused" then
              cmus_string = '|| ' .. cmus_string .. ''
          else
              cmus_string = '\> ' .. cmus_string .. ''
          end
      else
          cmus_string = '-- not playing --'
      end
      return cmus_string
  else
      return '-- not running --'
  end
end--}}}
