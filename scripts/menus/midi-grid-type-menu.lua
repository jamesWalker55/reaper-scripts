-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Grid type"},
    {name = "&Straight", cmd = 41003, check_state = true},
    {name = "&Dotted", cmd = 41005, check_state = true},
    {name = "S&wing", cmd = 41006, check_state = true},
    {name = "&Triplet", cmd = 41004, check_state = true},
    {name = ""},
    {name = "#Timebase"},
    {name = "Project beats", cmd = 40459, check_state = true},
    {name = "Source beats", cmd = 40470, check_state = true},
    {name = "Project time", cmd = 40460, check_state = true},
    {name = "Project sync", cmd = 40461, check_state = true},
    {name = "Help...", cmd = 40742},
    {name = ""},
    {name = "#Options"},
    {name = "Snap to grid", cmd = 1014, check_state = true},
    {name = "Snap relative to grid", cmd = 40829, check_state = true},
    {name = "Grid visible", cmd = 1017, check_state = true},
    {name = "Sync with arrange view's grid", cmd = 41022, check_state = true},
}

QuickMenu(SECTION_ID.MIDI, menu_table)
