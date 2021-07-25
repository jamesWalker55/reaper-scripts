-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.dev"

--[[
    pin functions
 ]]

-- get the channels a pin is connected to, example: `{ 1, 3, 4 }`
-- - pin_id: index starts from 1
-- - is_output: boolean
function GetPinChannels(track, fx_idx, is_output, pin_id)
    is_output = is_output and 1 or 0
    local low32_bitmask, hi32_bitmask = reaper.TrackFX_GetPinMappings(track, fx_idx, is_output, pin_id - 1)
    local channels = {}
    if low32_bitmask then
        for ch = 1, 32 do
            if low32_bitmask & 1 == 1 then table.insert(channels, ch) end
            low32_bitmask = low32_bitmask >> 1
        end
    end
    if hi32_bitmask then
        for ch = 33, 64 do
            if hi32_bitmask & 1 == 1 then table.insert(channels, ch) end
            hi32_bitmask = hi32_bitmask >> 1
        end
    end
    return channels
end

-- set the channels a pin is connected to, example: `{ 1, 3, 4 }`
-- - pin_id: index starts from 1
-- - is_output: boolean
-- - channels: array of channels to connect to
function SetPinChannels(track, fx_idx, is_output, pin_id, channels)
    is_output = is_output and 1 or 0
    local low32 = 0
    local hi32 = 0
    for _, ch in ipairs(channels) do
        if ch > 32 then
            local bitmask = 1 << (ch - 32 - 1)
            hi32 = hi32 + bitmask
        else
            local bitmask = 1 << (ch - 1)
            low32 = low32 + bitmask
        end
    end
    local val = reaper.TrackFX_SetPinMappings(track, fx_idx, is_output, pin_id - 1, low32, hi32)
    return val
end

function main()
    clear()
    local track = reaper.GetSelectedTrack(0, 0)
    local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    local fx_count = reaper.TrackFX_GetCount(track)
    local chans = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")

    p("This track has " .. fx_count .. " effects and " .. chans .. " channels: " .. track_name)
    for fx_idx = 0, fx_count - 1 do
        local _, pin_in, pin_out = reaper.TrackFX_GetIOSize(track, fx_idx)
        local _, fx_name = reaper.TrackFX_GetFXName(track, fx_idx, "");
        -- local low32_bitmask, hi32_bitmask = reaper.TrackFX_GetPinMappings(track, fx_idx, 1, 0)
        local channels = GetPinChannels(track, fx_idx, true, 1)
        p("Effect " .. fx_idx .. ": " .. inspect(fx_name))
        p("Input/Output pins: " .. pin_in .. " / " .. pin_out)
        p(channels)
        p("")
    end
    
    -- -- decrease track channels by 2
    -- reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", math.max(chans - 2, 2))
    
    -- -- increase track channels by 2
    -- reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", math.min(chans + 2, 64))

    -- -- open fx window with the plugin selected
    -- reaper.TrackFX_SetOpen(track, fx_idx, true)

    -- -- check if fx is enabled
    -- reaper.TrackFX_GetEnabled(track, fx_idx)
    reaper.defer(main)
end

reaper.defer(main)
