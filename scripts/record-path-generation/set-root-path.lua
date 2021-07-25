-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. "?.lua"
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. "?.lua"
package.path = _parent_path .. ";" .. _root_path

local config = require "lib.config"

require "lib.dev"
require "const"

-- local function main()
--     if not config.has_key(CONFIG_KEY) then
--         reaper.ShowMessageBox("Root path is not defined!", "Error", 0)
--         return
--     end

--     local root_path = config.get(CONFIG_KEY)
--     local end_separator = root_path:match("[/\\]$")
--     if not end_separator then root_path = root_path .. "/" end

--     local regex_pattern = "^" .. root_path .. ("[" .. CHAR_PATTERN .. "]"):rep(NAME_LENGTH) .. "$"
--     local has_match = getRecordPath():match(regex_pattern)

--     if has_match then
--         local msg = 'This project already has a valid audio path set:\n'
--         msg = msg .. '"' .. has_match .. '"'
--         reaper.ShowMessageBox(msg, "Recording path", 0)
--         return
--     end

--     local random_string, final_path

--     -- generate new path, try again if path already taken
--     repeat
--         random_string = string.random(NAME_LENGTH, CHAR_PATTERN)
--         final_path = root_path .. random_string
--     until not file.exists(final_path)

--     setRecordPath(final_path)

--     local msg = 'Audio path set to:\n'
--     msg = msg .. '"' .. getRecordPath() .. '"'
--     reaper.ShowMessageBox(msg, "Recording path", 0)
-- end

-- main()

local root_path
if config.has_key(CONFIG_KEY) then
    root_path = config.get(CONFIG_KEY)
else
    root_path = ""
end

local changed, new_path = reaper.GetUserInputs("Set audio file paths base", 1, "Base path:", root_path)

if changed then
    config.set(CONFIG_KEY, new_path)
end
