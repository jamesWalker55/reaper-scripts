local module = {}

local function addFx(track, fx_path, position, is_record_fx)
  local instantiate
  if position == nil then
    instantiate = -1  -- always create new effect
  else
    instantiate = -1000 - position  -- values with x <= -1000 represents insertion position
  end

  local inserted_pos = reaper.TrackFX_AddByName(track, fx_path, is_record_fx, instantiate)

  if inserted_pos == -1 then
    -- failed to insert fx, assume error is caused by invalid name
    return nil, "Invalid FX name given"
  end
  return inserted_pos
end

--[[ 
  add an fx to the track, given the name and the position (optional).
  position starts from 0.
 ]]
module.addFX = function(track, fx_path, position)
  return addFx(track, fx_path, position, false)
end

--[[ 
  add an fx to the track's recording fx chain, given the name and the position (optional).
  position starts from 0.
  to insert monitoring fx, use the master track as the argument
 ]]
module.addRecFX = function(track, fx_path, position)
  return addFx(track, fx_path, position, true)
end

return module