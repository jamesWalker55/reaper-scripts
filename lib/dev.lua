-- functions for easier debugging and testing

inspect = require "dev.inspect"

function clear() reaper.ShowConsoleMsg("") end

-- -- debug printing
-- function p(x)
--     if x == "" then x = " " end
--     if x == nil then x = "nil" end
--     if x == true then x = "true" end
--     if x == false then x = "false" end
--     reaper.ShowConsoleMsg(x)
--     reaper.ShowConsoleMsg("\n")
-- end

-- debug printing
function p(x)
    local x_str = inspect(x)
    reaper.ShowConsoleMsg(x_str)
    reaper.ShowConsoleMsg("\n")
end
