local api = {}

-- only get a single selected track,
-- return nil if no tracks/more than 1 tracks selected
api.getSingleSelectedTrack = function()
  local track = reaper.GetSelectedTrack2(0, 0, true)
  local track2 = reaper.GetSelectedTrack2(0, 1, true)
  -- if more than 1 track selected, return nil
  if track2 then return nil end

  return track
end

api.mouseContext = function()
  local context = {reaper.BR_GetMouseCursorContext()}
  local context_str
  for i, str in ipairs(context) do
    if i == 1 then
      context_str = context[1]
    elseif str ~= "" then
      context_str = context_str .. "/" .. str
    end
  end
  return context_str
end

-- generate the action to be taken based on what's under the mouse
api.objectUnderCursor = function()
  -- call GetMouseCursorContext once, otherwise the methods below return nothing
  reaper.BR_GetMouseCursorContext()

  -- try take first, it has higher priority
  local take_under_cursor = reaper.BR_GetMouseCursorContext_Take()
  if take_under_cursor then
    return "take", take_under_cursor
  end

  local track_under_cursor = reaper.BR_GetMouseCursorContext_Track()
  if track_under_cursor then
    return "track", track_under_cursor
  end
end

-- get the on/off state of a given main section command
-- if command has no state, return `nil`
api.getCommandState = function(command_id)
  local state_num = reaper.GetToggleCommandStateEx(0, command_id)
  if state_num == -1 then
      return nil
  else
      return state_num == 1
  end
end

return api