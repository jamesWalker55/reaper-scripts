-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. "?.lua"
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. "?.lua"
package.path = _parent_path .. ";" .. _root_path

require "lib.random-string"
local file = require "lib.file"
local config = require "lib.config"
local regex = require "lib.regex"

require "const"

local function getRecordPath()
    local _, audio_dir = reaper.GetSetProjectInfo_String(0, "RECORD_PATH", "", false)
    return audio_dir
end

local function setRecordPath(path)
    reaper.GetSetProjectInfo_String(0, "RECORD_PATH", path, true)
end

local function main()
    -- check if root path is set
    if not config.has_key(CONFIG_KEY) then
        reaper.ShowMessageBox("Root path is not defined, please define it first!", "Error", 0)
        return
    end

    -- get root path, and append a slash at the end
    local root_path = config.get(CONFIG_KEY)
    local end_separator = root_path:match("[/\\]$")
    if not end_separator then root_path = root_path .. "/" end

    -- try to match the current record path using regex
    local regex_pattern = "^" .. regex.escape_pattern(root_path) .. ("[" .. CHAR_PATTERN .. "]"):rep(NAME_LENGTH) .. "$"
    local has_match = getRecordPath():match(regex_pattern)

    -- if there is a match, then record path has been set previously already, skip it
    if has_match then
        local msg = 'This project already has a valid audio path set:\n'
        msg = msg .. '"' .. has_match .. '"'
        reaper.ShowMessageBox(msg, "Recording path", 0)
        return
    end

    -- otherwise, no match, record path has not been set yet
    local random_string, final_path

    -- generate new path, repeat until the path is not taken
    repeat
        random_string = string.random(NAME_LENGTH, CHAR_PATTERN)
        final_path = root_path .. random_string
    until not file.exists(final_path)

    -- set the new path
    setRecordPath(final_path)
    reaper.MarkProjectDirty(0)

    -- create the path, reaper doesn't do it automatically
    reaper.RecursiveCreateDirectory(final_path, 0)

    -- local msg = 'Audio path set to:\n'
    -- msg = msg .. '"' .. final_path .. '"'
    -- reaper.ShowMessageBox(msg, "Recording path", 0)
end

main()
