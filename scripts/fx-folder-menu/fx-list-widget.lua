local fxd = require "lib.fx-data"

local module = {}

local FLT_MIN, FLT_MAX = reaper.ImGui_NumericLimits_Float()
local BASE16 = {
  0x2D2D2DFF,
  0x393939FF,
  0x515151FF,
  0x747369FF,
  0xA09F93FF,
  0xD3D0C8FF,
  0xE8E6DFFF,
  0xF2F0ECFF,
}

module.generateMenuItems = function()
  local folders = fxd.fxfolders.get()
  local fxnames = fxd.fxnames.get()

  local menu_items = {}
  local i = 1
  for _, folder in ipairs(folders) do
    menu_items[i] = folder
    i = i + 1
    for _, item in ipairs(folder.items) do
      local meta_name, msg = fxd.fxItemMetaName(item, fxnames)
      assert(meta_name, msg)

      item.meta_name = meta_name
      menu_items[i] = item
      i = i + 1
    end
  end

  return menu_items
end

module.widget = function(ctx, menu_items)
  local width = 200
  local height = 12
  local output = nil

  -- set colors for selectables
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(), BASE16[2])
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(), BASE16[3])
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(), BASE16[5])

  -- wrap entire thing in group so we can measure its size later
  reaper.ImGui_BeginGroup(ctx)
  -- each column is a new group
  reaper.ImGui_BeginGroup(ctx)
  for i, item in ipairs(menu_items) do
    -- break into new line group if not enough space
    local remaining_height = ({reaper.ImGui_GetContentRegionAvail(ctx)})[2]
    if remaining_height < height then
      reaper.ImGui_EndGroup(ctx)
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_BeginGroup(ctx)
    end

    -- draw item
    local is_folder = item.items ~= nil
    if is_folder then
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(), BASE16[5])
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(), BASE16[5])
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), BASE16[1])
      reaper.ImGui_Selectable(ctx, item.name .. "##folder" .. i, true, nil, width, height)
      reaper.ImGui_PopStyleColor(ctx, 3)
    else
      local clicked = reaper.ImGui_Selectable(ctx, item.meta_name .. "##item" .. i, false, nil, width, height)
      if clicked then
        local fx_path = fxd.fxItemToPath(item)
        output = fx_path
      end
    end
  end

  -- undo colors
  reaper.ImGui_PopStyleColor(ctx, 3)
  -- end groups
  reaper.ImGui_EndGroup(ctx)
  reaper.ImGui_EndGroup(ctx)

  return output
end

module.window = function(ctx, menu_items)
  -- background color
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), BASE16[1])

  -- only allow resizing vertically
  reaper.ImGui_SetNextWindowSizeConstraints(ctx, -1, 0, -1, FLT_MAX)

  -- start window instance
  -- Calling ImGui_Begin will ALWAYS create a new window
  -- it can be opened fully or collapsed (triangle on top-left)
  -- args to ImGui_Begin, explained:
    -- ctx - the context
    -- str - name of the window
    -- bool - display close (x) button on top left
  -- return values explained:
    -- visible - whether contents are visible (see top-left triangle)
      -- if this is false, then you must NOT call ImGui_End
    -- close_not_pressed - stays as `true` normally, flashes to `false` when you click close
  local visible, close_not_pressed = reaper.ImGui_Begin(ctx, 'FX Folder Menu', true, reaper.ImGui_WindowFlags_NoCollapse())
  local close_pressed = not close_not_pressed

  if not visible then
    reaper.ImGui_PopStyleColor(ctx, 1)
    return close_pressed, nil
  end

  -- render widgets
  local fx_path = module.widget(ctx, menu_items)

  -- resize window width to match fx list
  local total_width = ({reaper.ImGui_GetItemRectSize(ctx)})[1]
  local current_height = ({reaper.ImGui_GetWindowSize(ctx)})[2]
  reaper.ImGui_SetWindowSize(ctx, total_width + reaper.ImGui_StyleVar_FramePadding() * 2, current_height)

  -- end window
  reaper.ImGui_End(ctx)

  -- undo background color
  reaper.ImGui_PopStyleColor(ctx, 1)

  return close_pressed, fx_path
end

return module