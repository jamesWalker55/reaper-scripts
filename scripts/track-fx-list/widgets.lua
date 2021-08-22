local tk = require "lib.track"
local folder_adder = require "scripts.fx-folder-menu.fx-list-widget"

local widgets = {}

local ctx

local TRACK_SHOW = {
  HIDE_CHAIN = 0,
  SHOW_CHAIN = 1,
  HIDE_FLOAT = 2,
  SHOW_FLOAT = 3
}

local ACTIONS = {
  SHOW_FX_BROWSER = 40271,
  SHOW_FX_CHAIN = 40291,
  LAST_FX_UI_IN_MCP = 42372,
  LAST_FX_UI_IN_TCP = 42335,
  TOGGLE_BYPASS = 8,
}

local colors = {}
colors.bg_selected = ({reaper.ImGui_ColorConvertHSVtoRGB(0, 0, 1, 0.12)})[1]
colors.bg_hover = ({reaper.ImGui_ColorConvertHSVtoRGB(0, 0, 1, 0.16)})[1]
colors.bg_active = ({reaper.ImGui_ColorConvertHSVtoRGB(0, 0, 1, 0.3)})[1]
colors.text_disabled = ({reaper.ImGui_ColorConvertHSVtoRGB(1 / 7.0, 0.7, 0.7, 1.0)})[1]
colors.text_offline = ({reaper.ImGui_ColorConvertHSVtoRGB(0, 0, 0.7, 0.4)})[1]
colors.text_add_fx = ({reaper.ImGui_ColorConvertHSVtoRGB(0, 0, 0.7, 0.6)})[1]
colors.menu_text = ({reaper.ImGui_ColorConvertHSVtoRGB(0, 0, 0.7, 0.6)})[1]
colors.btn_enable = ({reaper.ImGui_ColorConvertHSVtoRGB(2, 0.5, 0.7, 1)})[1]
colors.btn_disable = ({reaper.ImGui_ColorConvertHSVtoRGB(0, 0.5, 0.7, 1)})[1]

widgets.setupDependencies = function(imgui_context)
  ctx = imgui_context
end

widgets.setupColors = function()
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(), colors.bg_selected)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(), colors.bg_active)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(), colors.bg_hover)
end

widgets.unsetupColors = function()
  reaper.ImGui_PopStyleColor(ctx, 3)
end

widgets.getMods = function()
  local mod_bits = reaper.ImGui_GetKeyMods(ctx)
  local mods = {}
  mods.ctrl = (mod_bits & reaper.ImGui_KeyModFlags_Ctrl()) ~= 0
  mods.shift = (mod_bits & reaper.ImGui_KeyModFlags_Shift()) ~= 0
  mods.alt = (mod_bits & reaper.ImGui_KeyModFlags_Alt()) ~= 0
  mods.super = (mod_bits & reaper.ImGui_KeyModFlags_Super()) ~= 0
  return mods
end

widgets.trackName = function(media_track)
  local track_num = reaper.GetMediaTrackInfo_Value(media_track, "IP_TRACKNUMBER")
  local _, track_name

  if track_num == -1 then
    track_num = 0
    track_name = "Master"
  else
    _, track_name = reaper.GetSetMediaTrackInfo_String(media_track, "P_NAME", "", false)
    if track_name == "" then
      track_name = "(untitled)"
    end
  end

  reaper.ImGui_Text(ctx, ("[%d] %s"):format(track_num, track_name))
end

-- fx_index starts from 1
widgets.fxItem = function(media_track, fx_index, remove_colon)
  fx_index = fx_index - 1
  local fx_enabled = reaper.TrackFX_GetEnabled(media_track, fx_index)
  local fx_offline = reaper.TrackFX_GetOffline(media_track, fx_index)
  local fx_open = reaper.TrackFX_GetOpen(media_track, fx_index)
  local hwnd = reaper.TrackFX_GetFloatingWindow(media_track, fx_index)
  local fx_floating = hwnd ~= nil
  local _, fx_name = reaper.TrackFX_GetFXName(media_track, fx_index, "")

  if remove_colon then
    local matched_name = fx_name:match(": *(.*)")
    if matched_name then fx_name = matched_name end
  end

  --[[ set up styling and the item itself ]]
  local styles_count = 0
  if not fx_enabled then
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), colors.text_disabled)
    styles_count = styles_count + 1
  end
  if fx_offline then
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), colors.text_offline)
    styles_count = styles_count + 1
  end
  local clicked, _ = reaper.ImGui_Selectable(ctx, fx_name .. "##" .. "FX" .. fx_index, fx_open)
  reaper.ImGui_PopStyleColor(ctx, styles_count)

  --[[ set up actions ]]
  -- click actions
  if clicked then
    local mods = widgets.getMods()
    if mods.ctrl and mods.shift then
      reaper.TrackFX_SetOffline(media_track, fx_index, not fx_offline)
    elseif mods.ctrl then
      if fx_floating then
        reaper.TrackFX_Show(media_track, fx_index, TRACK_SHOW.HIDE_FLOAT)
      elseif fx_open then
        reaper.TrackFX_Show(media_track, fx_index, TRACK_SHOW.HIDE_CHAIN)
      else
        reaper.TrackFX_Show(media_track, fx_index, TRACK_SHOW.SHOW_CHAIN)
      end
    elseif mods.shift then
      reaper.TrackFX_SetEnabled(media_track, fx_index, not fx_enabled)
    elseif mods.alt then
      reaper.TrackFX_Delete(media_track, fx_index)
    else
      if fx_floating then
        reaper.TrackFX_Show(media_track, fx_index, TRACK_SHOW.HIDE_FLOAT)
      else
        reaper.TrackFX_Show(media_track, fx_index, TRACK_SHOW.SHOW_FLOAT)
      end
    end
  end
  
  --[[ drag and drop ]]

  local mouse_within_window = reaper.ImGui_IsWindowHovered(ctx, reaper.ImGui_HoveredFlags_AllowWhenBlockedByActiveItem())

  -- item as a draggable object
  if reaper.ImGui_BeginDragDropSource(ctx) then
    -- Set payload to carry the index of our item (could be anything)
    reaper.ImGui_SetDragDropPayload(ctx, 'FX_INDEX', tostring(fx_index))

    -- anything created here will become a preview tooltip that shows up as you drag
    local mods = widgets.getMods()

    if mouse_within_window then
      -- if mouse is within window
      if mods.ctrl then
        reaper.ImGui_Text(ctx, "Copy FX")
      else
        reaper.ImGui_Text(ctx, "Move FX")
      end
    else
      -- if mouse is outside window
      if mods.alt then
        reaper.ImGui_Text(ctx, "Move FX")
      else
        reaper.ImGui_Text(ctx, "Copy FX")
      end
    end
    reaper.ImGui_EndDragDropSource(ctx)
  end

  -- item as a release destination
  if reaper.ImGui_BeginDragDropTarget(ctx) then
    local rv, src_fx_index_str = reaper.ImGui_AcceptDragDropPayload(ctx, 'FX_INDEX')
    if rv then
      local src_fx_index = tonumber(src_fx_index_str)
      if widgets.getMods().ctrl then
        tk.copyFxToTrack(media_track, src_fx_index, media_track, fx_index)
      else
        tk.moveFxToTrack(media_track, src_fx_index, media_track, fx_index)
      end
    end
    reaper.ImGui_EndDragDropTarget(ctx)
  end

  -- item dragged outside window
  -- there is no native way to detect drags outside the window, so this is as good as it gets
  if reaper.ImGui_IsItemDeactivated(ctx) and not mouse_within_window then
    local mode, dest_obj = Api.objectUnderCursor()
    if mode == "track" then
      local same_track = dest_obj == media_track
      -- do nothing if same track
      if not same_track then
        if widgets.getMods().alt then
          tk.moveFxToTrack(media_track, fx_index, dest_obj)
        else
          tk.copyFxToTrack(media_track, fx_index, dest_obj)
        end
      end
    elseif mode == "take" then
      if widgets.getMods().alt then
        tk.moveFxToTake(media_track, fx_index, dest_obj)
      else
        tk.copyFxToTake(media_track, fx_index, dest_obj)
      end
    end
  end

  --[[ right click menu ]]
  reaper.ImGui_OpenPopupOnItemClick(ctx, 'fx popup menu##' .. fx_index, reaper.ImGui_PopupFlags_MouseButtonRight())
  
  if reaper.ImGui_BeginPopupContextItem(ctx, 'fx popup menu##' .. fx_index) then
    -- set FX enabled
    if reaper.ImGui_MenuItem(ctx, (fx_enabled and "Disable" or "Enable") .. "##Toggle FX Exabled", nil, false, true) then
      reaper.TrackFX_SetEnabled(media_track, fx_index, not fx_enabled)
    end
    -- delete FX
    if reaper.ImGui_MenuItem(ctx, "Delete", nil, false, true) then
      reaper.TrackFX_Delete(media_track, fx_index)
    end
    -- set FX offline
    if reaper.ImGui_MenuItem(ctx, "Toggle offline", nil, false, true) then
      reaper.TrackFX_SetOffline(media_track, fx_index, not fx_offline)
    end

    reaper.ImGui_Separator(ctx)

    -- rename FX
    reaper.ImGui_TextColored(ctx, colors.menu_text, "Rename")
    local _, fx_name = reaper.TrackFX_GetFXName(media_track, fx_index, "")
    reaper.ImGui_PushItemWidth(ctx, -({reaper.ImGui_NumericLimits_Float()})[1])
    _, fx_name = reaper.ImGui_InputText(ctx, '##FX Name', fx_name)
    if reaper.ImGui_IsItemDeactivatedAfterEdit(ctx) then
      tk.renameFX(media_track, fx_index, fx_name)
    end
    reaper.ImGui_PopItemWidth(ctx)

    reaper.ImGui_EndPopup(ctx)
  end
end

widgets.finalItem = function(media_track, fx_count)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), colors.text_add_fx)
  local clicked, _ = reaper.ImGui_Selectable(ctx, "+ Add FX", false)
  reaper.ImGui_PopStyleColor(ctx)

  if clicked then
    reaper.Main_OnCommand(ACTIONS.SHOW_FX_BROWSER, 0)
  end

  -- item as a release destination
  if reaper.ImGui_BeginDragDropTarget(ctx) then
    local rv, src_fx_index_str = reaper.ImGui_AcceptDragDropPayload(ctx, 'FX_INDEX')
    if rv then
      local src_fx_index = tonumber(src_fx_index_str)
      local mods = widgets.getMods()
      if mods.ctrl then
        reaper.TrackFX_CopyToTrack(media_track, src_fx_index, media_track, fx_count, false)
      else
        reaper.TrackFX_CopyToTrack(media_track, src_fx_index, media_track, fx_count, true)
      end
    end
    reaper.ImGui_EndDragDropTarget(ctx)
  end
end

widgets.fxToggle = function(media_track, width, height)
  -- local gap = reaper.ImGui_StyleVar_ItemSpacing()
  -- local toggle_btn_width = 32
  -- if reaper.ImGui_Button(ctx, "FX chain", width - gap - toggle_btn_width) then
  --   reaper.Main_OnCommand(ACTIONS.SHOW_FX_CHAIN, 0)
  -- end

  -- reaper.ImGui_SameLine(ctx)

  local is_bypassed = Api.getCommandState(ACTIONS.TOGGLE_BYPASS)
  if reaper.ImGui_Button(ctx, (is_bypassed and "FX Off" or "FX On"), width, height) then
    reaper.Main_OnCommand(ACTIONS.TOGGLE_BYPASS, 0)
  end
end

return widgets