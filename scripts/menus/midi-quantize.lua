-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "Quantize...", cmd = 40009},
    {name = "Unquantize selected notes", cmd = 40402},
    {name = ""},
    {name = "#Quantize to grid..."},
    {name = "Note position", cmd = 40469},
    {name = "Note position and end", cmd = 40729},
    {name = "Events", cmd = 40728},
    {name = ""},
    {name = "#Quantize using last quantize dialog settings..."},
    {name = "Notes", cmd = 40406},
    {name = "Note position", cmd = 41768},
    {name = "Events", cmd = 40727},
    {name = ""},
    {name = "Freeze/Apply quantization", cmd = 40403},
}

QuickMenu(SECTION_ID.MIDI, menu_table)
