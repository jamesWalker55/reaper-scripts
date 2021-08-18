local chunk = require "lib.chunk"
local arrchunk = require "lib.arrchunk"

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

module.RENAME_FX_POS = {
  JS = 3,
  AU = 4,
  VST = 5,
}

--[[
  set the alternative name of an FX by editing the state chunk.
  an empty string clears the alternative name.
  position starts from 0.
 ]]
module.renameFX = function(track, fx_id, name)
  local success, cnk = reaper.GetTrackStateChunk(track, "", false)
  if not success then return nil, "Failed to obtain track state chunk" end

  -- failsafe
  if not arrchunk._testChunk(cnk) then return nil, "Chunk parsed incorrectly, please check arrchunk implementation" end

  local arr = arrchunk.fromChunk(cnk)

  local fxchain = nil
  for _, item in ipairs(arr) do
    if type(item) == "table" and item[1]:find("^%s*FXCHAIN%s*$") then
      fxchain = item
      break
    end
  end
  if fxchain == nil then return nil, "FX chain not found in track state chunk" end

  local fx = nil
  local fx_type = nil
  for _, item in ipairs(fxchain) do
    if type(item) == "table" then
      local first_word = item[1]:match("%S+")
      if (first_word == "VST" or first_word == "AU" or first_word == "JS") then
        if fx_id == 0 then
          fx = item
          fx_type = first_word
          break
        else
          fx_id = fx_id - 1
        end
      end
    end
  end
  if fx == nil then return nil, "FX " .. fx_id .. " not found in track state chunk" end

  local line_args = chunk.splitLine(fx[1])
  if line_args == nil then return nil, "Error parsing line: " .. fx[1] end

  -- failsafe
  if table.concat(line_args, " ") ~= fx[1] then return nil, "Failsafe: FX line might be parsed incorrectly, please debug this line: " .. fx[1] end

  line_args[module.RENAME_FX_POS[fx_type]] = chunk.escape_string(name)
  fx[1] = table.concat(line_args, " ")

  local success = reaper.SetTrackStateChunk(track, arrchunk.toChunk(arr), false)
  if not success then return nil, "Failed to set track state chunk" end

  return true
end

-- -- alternative implementation with regex searching
-- -- should be faster, but benchmarks say it's about the same
-- module.renameFX = function(track, fx_id, name)
--   local success, cnk = reaper.GetTrackStateChunk(track, "", false)
--   if not success then return nil, "Failed to obtain track state chunk" end

--   local fx_pos = 0
--   for _ = 0, fx_id do
--     fx_pos = chunk.findElement(cnk, {"VST", "AU", "JS"}, fx_pos + 1)
--     if fx_pos == nil  then return nil, "Failed to find FX with id " .. fx_id end
--   end
--   if fx_pos == 0 then return nil, "Invalid FX id: " .. fx_id end

--   local nl_pos = cnk:find("\n", fx_pos)

--   local fx_line = cnk:sub(fx_pos, nl_pos - 1)
--   local fx_args = chunk.splitLine(fx_line)
--   -- failsafe
--   if table.concat(fx_args, " ") ~= fx_line then return nil, "Failsafe: FX line might be parsed incorrectly, please debug this line: " .. fx[1] end

--   local fx_type = fx_line:match("%w+")

--   fx_args[module.RENAME_FX_POS[fx_type]] = chunk.escape_string(name)
--   fx_line = table.concat(fx_args, " ")

--   local success = reaper.SetTrackStateChunk(track, cnk:sub(0, fx_pos - 1) .. fx_line .. cnk:sub(nl_pos, -1), false)
--   if not success then return nil, "Failed to set track state chunk" end

--   return true
-- end

return module