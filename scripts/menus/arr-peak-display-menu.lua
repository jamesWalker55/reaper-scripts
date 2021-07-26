-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Display peaks as..."},
    {name = "Normal peaks", cmd = 42301, check_state = true},
    {name = "Spectral peaks", cmd = 42073, check_state = true},
    {name = "Spectrogram", cmd = 42294, check_state = true},
    {name = "Spectrogram and peaks", cmd = 42295, check_state = true},
    {name = ""},
    {name = "#Display options"},
    {name = "Rectify peaks", cmd = 42307, check_state = true},
    {name = "Scale peaks by square root (half of range is 12dB rather than 6dB)", cmd = 42306, check_state = true},
    {name = "Peak display settings...", cmd = 42074, check_state = true},
    {name = ""},
    {name = "#Peak options"},
    {name = ">Rebuild peaks"},
    {name = "All items", cmd = 40048},
    {name = "Selected items", cmd = 40441},
    {name = "<Missing peaks", cmd = 40047},
    {name = "Prevent spectral peaks/spectrogram for selected tracks", cmd = 42075},
    {name = "Remove all peak cache files", cmd = 40097},
}


QuickMenu(SECTION_ID.MAIN, menu_table)
