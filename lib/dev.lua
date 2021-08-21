-- functions for easier debugging and testing

inspect = require "dev.inspect"
json = require "dev.json"

function clear() reaper.ShowConsoleMsg("") end

-- debug printing
function p(x)
  local x_str = inspect(x)
  reaper.ShowConsoleMsg(x_str)
  reaper.ShowConsoleMsg("\n")
end

function copy(obj)
  if type(obj) == "string" then
    reaper.CF_SetClipboard(obj)
  else
    reaper.CF_SetClipboard(json.encode(obj))
  end
end

function paste()
  return reaper.CF_GetClipboard()
end

table.keys = function(tb)
  local keys = {}
  local i = 1
  for key, _ in pairs(tb) do
    keys[i] = key
    i = i + 1
  end
  return keys
end
