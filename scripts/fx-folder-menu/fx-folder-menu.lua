-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. '?.lua'
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. '?.lua'
package.path = _parent_path .. ';' .. _root_path

local tracks = require "lib.tracks"
local track = require "lib.track"

local list = require "fx-list-widget"

local ctx = reaper.ImGui_CreateContext('fx-folder-menu')
local menu_items = list.generateMenuItems()

local function loop()
  local close_pressed, fx_path = list.window(ctx, menu_items)

  if fx_path then
    local fx_added = false
    for _, t in tracks.iterSelected(true) do
      track.addFX(t, fx_path)
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

reaper.defer(loop)