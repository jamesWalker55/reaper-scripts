-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. "?.lua"
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. "?.lua"
package.path = _parent_path .. ";" .. _root_path

require "lib.str-funcs"
local tks = require "lib.tracks"

local function setTrackName(track, name)
  local rv, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
  return rv
end

local track_names = reaper.CF_GetClipboard():splitlines()
for i, track in tks.iterSelected(false) do
  if track_names[i] ~= nil then
    setTrackName(track, track_names[i])
  else
    break
  end
end
