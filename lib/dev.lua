-- functions for easier debugging and testing

inspect = require "dev.inspect"

function clear() reaper.ShowConsoleMsg("") end

-- debug printing
function p(x)
  local x_str = inspect(x)
  reaper.ShowConsoleMsg(x_str)
  reaper.ShowConsoleMsg("\n")
end
