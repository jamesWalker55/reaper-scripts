-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Toggle all windows"},
    {name = "All floating windows (except mixer and docker)", cmd = 41080},
    {name = "All floating windows (except docker)", cmd = 41079},
    {name = ""},
    {name = "#Arrangement"},
    {name = "Mixer", cmd = 40078, check_state = true},
    {name = "Transport", cmd = 40259, check_state = true},
    {name = "Media explorer", cmd = 50124, check_state = true},
    {name = "FX browser", cmd = 40271, check_state = true},
    {name = "All dockers", cmd = 40279, check_state = true},
    {name = ""},
    {name = "#Tracks"},
    {name = "Track manager", cmd = 40906, check_state = true},
    {name = "Routing matrix", cmd = 40251, check_state = true},
    {name = "Grouping matrix", cmd = 40768, check_state = true},
    {name = "Wiring diagram", cmd = 42031, check_state = true},
    {name = ""},
    {name = "#Project info"},
    {name = "Media item/take properties", cmd = 41589, check_state = true},
    {name = "Project bay", cmd = 41157, check_state = true},
    {name = "Region/marker manager", cmd = 40326, check_state = true},
    {name = "Marker list (SWS)", cmd = "_SWSMARKERLIST1", check_state = true},
    {name = "Notes (SWS)", cmd = "_S&M_SHOW_NOTES_VIEW", check_state = true},
    {name = "Navigator", cmd = 40268, check_state = true},
    {name = "Performance meter", cmd = 40240, check_state = true},
    {name = ""},
    {name = "#Tools"},
    {name = "Virtual MIDI Keyboard", cmd = 40377, check_state = true},
    {name = "Big clock", cmd = 40378, check_state = true},
    {name = "Video", cmd = 50125, check_state = true},
    {name = ""},
    {name = "#Settings"},
    {name = "Screen/track/item sets", cmd = 40422, check_state = true},
    {name = "Peak display settings", cmd = 42074, check_state = true},
}


QuickMenu(SECTION_ID.MAIN, menu_table)
