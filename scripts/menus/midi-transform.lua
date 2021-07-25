-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

-- check if multiple notes are selected in the active MIDI window
function MultipleSelected()
    -- Get HWND, then current take
    local hwnd = reaper.MIDIEditor_GetActive()
    local take = reaper.MIDIEditor_GetTake(hwnd)

    -- get notes count
    local _, notes, _, _ = reaper.MIDI_CountEvts(take)

    local atLeastOneSelected = false

    for i = 0, notes - 1 do
        local _, selected, _, _, _, _, _, _ = reaper.MIDI_GetNote(take, i)
        if selected == true then -- find which notes are selected
            if atLeastOneSelected then
                return true
            else
                atLeastOneSelected = true
            end
        end
    end
    return false
end

local menu_table

if MultipleSelected() then
    menu_table = {
        {name = "#Flip selected notes..."},
        {name = "Vertically", cmd = 40908},
        {name = "Vertically (preserving pitch)", cmd = 40906},
        {name = "Horizontally", cmd = 40902},
        {name = ""},
        {name = "#Other transformations"},
        {name = "Join notes", cmd = 40456},
        {name = "Legato notes", cmd = 40765},
        {name = "Legato notes (Relative note spacing)", cmd = 40766},
        {name = ""},
        {name = "#Muting"},
        {name = "Toggle mute events", cmd = 40055},
        {name = "Mute events", cmd = 40057},
        {name = "Unmute events", cmd = 40058},
    }
else
    menu_table = {
        {name = "#Flip all notes..."},
        {name = "Flip vertically", cmd = 40907},
        {name = "Flip vertically (preserving pitch)", cmd = 40905},
        {name = "Flip horizontally", cmd = 40019},
        {name = ""},
        {name = "#Other transformations"},
        {name = "Join notes", cmd = 40456},
        {name = "Legato notes", cmd = 40765},
        {name = "Legato notes (Relative note spacing)", cmd = 40766},
        {name = ""},
        {name = "#Muting"},
        {name = "Toggle mute events", cmd = 40055},
        {name = "Mute events", cmd = 40057},
        {name = "Unmute events", cmd = 40058},
    }
end

QuickMenu(SECTION_ID.MIDI, menu_table)
