local api = {}
api = {}

-- api.currentProject = function()
--     local project, path = reaper.EnumProjects(-1)
--     return project
-- end

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

-- archie's trackFX rename function
-- thank you archie
api.renameTrackFx = function(Track,idx_fx,newName);
  local strT,found,slot = {};
  local Pcall,FXGUID = pcall(reaper.TrackFX_GetFXGUID,Track,idx_fx);
  if not Pcall or not FXGUID then return false end;
  local retval,str = reaper.GetTrackStateChunk(Track,"",false);
  for l in (str.."\n"):gmatch(".-\n")do table.insert(strT,l)end;
  for i = #strT,1,-1 do;
    if strT[i]:match(FXGUID:gsub("%p","%%%0"))then found = true end;
    if strT[i]:match("^<")and found and not strT[i]:match("JS_SER")then;
      found = nil;
      local nStr = {};
      for S in strT[i]:gmatch("%S+")do;
        if not X then nStr[#nStr+1] = S else nStr[#nStr] = nStr[#nStr].." "..S end;
        if S:match('"') and not S:match('""')and not S:match('".-"') then;
          if not X then;X = true;else;X = nil;end;
        end;
      end;
      if strT[i]:match("^<%s-JS")then;
        slot = 3;
      elseif strT[i]:match("^<%s-AU")then;
        slot = 4;
      elseif strT[i]:match("^<%s-VST")then;
        slot = 5;
      end;
      if not slot then error("Failed to rename",2)end;
      nStr[slot] = newName:gsub(newName:gsub("%p","%%%0"),'"%0"');
      nStr[#nStr+1]="\n";
      strT[i] = table.concat(nStr," ");
      break;
    end;
  end;
  return reaper.SetTrackStateChunk(Track,table.concat(strT),false);
end;

return api