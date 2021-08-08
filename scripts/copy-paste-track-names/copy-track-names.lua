-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. "?.lua"
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. "?.lua"
package.path = _parent_path .. ";" .. _root_path

local tks = require "lib.tracks"

local track_names = {}
for i, track in tks.iterSelected(false) do
  local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  table.insert(track_names, name)
end

track_names = table.concat(track_names, "\n")
reaper.CF_SetClipboard(track_names)
