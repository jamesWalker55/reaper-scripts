-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Color notes/events by..."},
    {name = "&Velocity", cmd = 40738, check_state = true},
    {name = "&Channel", cmd = 40739, check_state = true},
    {name = "&Source, using colormap", cmd = 40741, check_state = true},
    {name = "&Track custom color", cmd = 40768, check_state = true},
    {name = "&Pitch", cmd = 40740, check_state = true},
    {name = "Media &item custom color", cmd = 40769, check_state = true},
    {name = "V&oice", cmd = 41114, check_state = true},
    {name = ""},
    {name = ">Color &map..."},
    {name = "&Load from file...", cmd = 40498},
    {name = "<&Clear", cmd = 40499},
}

QuickMenu(SECTION_ID.MIDI, menu_table)
