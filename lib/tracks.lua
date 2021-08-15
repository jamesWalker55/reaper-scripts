local tracks = {}

--[[
iterator that returns all selected tracks in the current project. Index starts at 1.

    for i, track in tracks.iterSelected(true) do print(i, track) end
]]
tracks.iterSelected = function(want_master)
  if want_master == nil then want_master = true end

  local function iter(_, i)
    i = i + 1
    local track = reaper.GetSelectedTrack2(0, i - 1, want_master)
    if track then
      return i, track
    end
  end
  return iter, nil, 0
end

return tracks