local module = {}

--[[
  get/set state chunk for a track. argument `chunk` is optional
 ]]
module.track = function(track, chunk)
  if chunk == nil then
    local rv, xml = reaper.GetTrackStateChunk(track, "", false)
    if not rv then return nil, "Failed to get track state chunk" end
    return xml
  else
    local rv = reaper.SetTrackStateChunk(track, chunk, false)
    if not rv then return nil, "Failed to set track state chunk" end
    return true
  end
end

return module
