-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Zoom to selected items..."},
    {name = "Just zoom", cmd = "_SWS_TOGZOOMIONLY", check_state = true},
    {name = "Only horizontally", cmd = "_SWS_TOGZOOMHORIZ_ITEMS", check_state = true},
    {name = "Minimize other tracks", cmd = "_SWS_TOGZOOMIONLYMIN", check_state = true},
    {name = "Hide other tracks", cmd = "_SWS_TOGZOOMIONLYHIDE", check_state = true},
    {name = ""},
    {name = "#Zoom to selected tracks and time selection..."},
    {name = "Just zoom", cmd = "_SWS_TOGZOOMTT", check_state = true},
    {name = "Minimize other tracks", cmd = "_SWS_TOGZOOMTTMIN", check_state = true},
    {name = "Hide other tracks", cmd = "_SWS_TOGZOOMTTHIDE", check_state = true},
    {name = ""},
    {name = "#Zoom to..."},
    {name = "Time selection", cmd = "_SWS_TOGZOOMHORIZ_TSEL", check_state = true},
    {name = "Selected envelope in time selection", cmd = "_WOL_FZOOMSELENVTIMESEL", check_state = true},
    {name = ""},
    {name = "#Toggle track height to..."},
    {name = "Max height", cmd = 40113, check_state = true},
    {name = "Min height", cmd = 40110, check_state = true},
    {name = ""},
    {name = "#SWS Options"},
    {name = "Obey track height lock for vertical zoom actions", cmd = "_NF_TOGGLE_OBEY_TRACK_HEIGHT_LOCK", check_state = true},
}

QuickMenu(SECTION_ID.MAIN, menu_table)
