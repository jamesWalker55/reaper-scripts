local tracks = {}

--[[
iterator that returns all selected tracks in the current project. Index starts at 1.

    for i, proj, path in tracks.iterSelected(true) do print(i, proj, path) end
]]
tracks.iterSelected = function(want_master)
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