-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. "?.lua"
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. "?.lua"
package.path = _parent_path .. ";" .. _root_path

local config = require "lib.config"

require "const"

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
