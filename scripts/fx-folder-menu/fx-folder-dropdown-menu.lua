-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. '?.lua'
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. '?.lua'
package.path = _parent_path .. ';' .. _root_path

local tracks = require "lib.tracks"
local track = require "lib.track"

local list = require "fx-list-widget"

local ctx = reaper.ImGui_CreateContext('fx-folder-menu')
local menu_items = list.generateMenuItems()

local font = reaper.ImGui_CreateFont("Inter", 12)
reaper.ImGui_AttachFont(ctx, font)

local function loop()
  reaper.ImGui_PushFont(ctx, font)
  local close_pressed, fx_path = list.window(ctx, menu_items)
  reaper.ImGui_PopFont(ctx)

  if fx_path then
    local fx_added = false
    for _, t in tracks.iterSelected(true) do
      local fx_idx = track.addFx(t, fx_path)
      reaper.TrackFX_Show(t, fx_idx, 3)
      fx_added = true
    end
    if fx_added then close_pressed = true end
  end

  if close_pressed then
    reaper.ImGui_DestroyContext(ctx)
  else
    reaper.defer(loop)
  end
end

local function main()
  if #tracks.selected(true) == 0 then return end

  -- list.setNextWindowPos(ctx)
  reaper.defer(loop)
end

main()
