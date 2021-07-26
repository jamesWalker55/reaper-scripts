-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Track envelopes"},
    {name = "Toggle display all envelopes", cmd = 41152, check_state = true},
    {name = "Activate/bypass envelope for last touched FX parameter", cmd = 41983},
    {name = ""},
    {name = "#Toggle envelope visibility"},
    {name = "Volume", cmd = 40406},
    {name = "Pan", cmd = 40407},
    {name = "Trim", cmd = 42020},
    {name = "Mute", cmd = 40867},
    {name = "Pre-FX volume", cmd = 40408},
    {name = "Pre-FX pan", cmd = 40409},
    {name = ""},
    {name = "#Volume and trim envelope"},
    {name = "Apply volume to trim (clear volume)", cmd = 42019},
    {name = "Apply trim to volume (clear trim)", cmd = 42018},
    {name = "Swap volume and trim", cmd = 42021},
}


QuickMenu(SECTION_ID.MAIN, menu_table)
