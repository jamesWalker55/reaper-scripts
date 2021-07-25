-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Toggle grid modifiers (SWS)"},
    {name = "&Dotted", cmd = "_NF_ME_TOGGLEDOTTED", check_state = true},
    {name = "S&wing", cmd = "_NF_ME_TOGGLESWING", check_state = true},
    {name = "&Triplet", cmd = "_NF_ME_TOGGLETRIPLET", check_state = true},
    {name = ""},
    {name = "#Options"},
    {name = "Snap to grid", cmd = 1014, check_state = true},
    {name = "Snap relative to grid", cmd = 40829, check_state = true},
    {name = "Grid visible", cmd = 1017, check_state = true},
    {name = "Sync with arrange view's grid", cmd = 41022, check_state = true},
}

QuickMenu(SECTION_ID.MIDI, menu_table)
