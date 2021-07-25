-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. "?.lua"
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. "?.lua"
package.path = _parent_path .. ";" .. _root_path

require "lib.dev"
Api = require "api"
local config = require "lib.config"
local w = require "widgets"
local ctx = reaper.ImGui_CreateContext('Simple FX List', reaper.ImGui_ConfigFlags_DockingEnable())

-- set up context
w.setupDependencies(ctx)

-- set the last-used dock position (if config exists)
local config_key = {
  dock_pos = "track-fx-list-dock-position",
  remove_colon = "track-fx-list-remove-colon",
}

-- settings
local next_dock_id
local remove_colon
if config.has_key(config_key.remove_colon) then
  remove_colon = config.get(config_key.remove_colon) == "true"
else
  remove_colon = false
end

-- set some constants
local fx_toggle_height = 16

-- right click menu for docking
local function settingsContextMenu()
  reaper.ImGui_OpenPopupOnItemClick(ctx, 'settings', reaper.ImGui_PopupFlags_MouseButtonRight())

  -- get dock id, must be obtained outside popup context
  local current_dock_id = reaper.ImGui_GetWindowDockID(ctx)
  local is_docked = current_dock_id < 0

  if reaper.ImGui_BeginPopupContextItem(ctx, 'settings') then

    --[[ Dock / Undock ]]

    if reaper.ImGui_MenuItem(ctx, (is_docked and "Undock" or "Dock"), nil, false, true) then
      if is_docked then
        next_dock_id = 0
      else
        if config.has_key(config_key.dock_pos) then
          next_dock_id = tonumber(config.get(config_key.dock_pos))
        else
          next_dock_id = -1 -- default dock if no config is found
        end
      end
    end

    --[[ Remove text before first colon ':' ]]

    remove_colon = config.get(config_key.remove_colon) == "true"

    if reaper.ImGui_MenuItem(ctx, "Remove text before first colon ':'", nil, remove_colon, true) then
      remove_colon = not remove_colon
      config.set(config_key.remove_colon, (remove_colon and "true" or "false"))
    end

    reaper.ImGui_EndPopup(ctx)
  end

end

function TrackWidgets(track)
  w.trackName(track)
  settingsContextMenu()

  reaper.ImGui_Separator(ctx)

  local available_width, available_height = reaper.ImGui_GetContentRegionAvail(ctx)
  local gap = reaper.ImGui_StyleVar_ItemSpacing()

  if reaper.ImGui_BeginChild(ctx, 'ChildL', available_width, available_height - fx_toggle_height - gap / 4.0, false) then
    w.setupColors()

    local fx_count = reaper.TrackFX_GetCount(track)
    for i = 1, fx_count do
      w.fxItem(track, i, remove_colon)
    end

    w.finalItem(track, fx_count)

    w.unsetupColors()

    reaper.ImGui_EndChild(ctx)
  end

  w.fxToggle(track, available_width, fx_toggle_height)
end

function Window()
  local track = Api.getSingleSelectedTrack()

  if track then
    TrackWidgets(track)
  end
end

local _PREV_DOCK_ID, _CURRENT_DOCK_ID

function MainLoop()
  if next_dock_id ~= nil then
    -- only needs to be called once to be set
    reaper.ImGui_SetNextWindowDockID(ctx, next_dock_id)
    next_dock_id = nil
  end

  local visible, open = reaper.ImGui_Begin(ctx, 'FX List', true, reaper.ImGui_WindowFlags_NoCollapse())
  if visible then
    _CURRENT_DOCK_ID = reaper.ImGui_GetWindowDockID(ctx)

    -- if dock id changed, and is now docked (not floating)
    if _PREV_DOCK_ID ~= nil and _CURRENT_DOCK_ID ~= nil and _PREV_DOCK_ID ~= _CURRENT_DOCK_ID and _CURRENT_DOCK_ID < 0 then
      -- remember the dock id
      config.set(config_key.dock_pos, tostring(_CURRENT_DOCK_ID))
    end

    reaper.ImGui_CaptureKeyboardFromApp(ctx, false)
    Window()
    _PREV_DOCK_ID = _CURRENT_DOCK_ID
    reaper.ImGui_End(ctx)
  end

  if open then
    reaper.defer(MainLoop)
  else
    reaper.ImGui_DestroyContext(ctx)
  end
end

reaper.defer(MainLoop)