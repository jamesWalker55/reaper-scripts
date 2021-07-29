-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
  {name = "#Show take envelopes..."},
  {name = "Volume envelope", cmd = 40693},
  {name = "Pan envelope", cmd = 40694},
  {name = "Pitch envelope", cmd = 41612},
  {name = "Mute envelope", cmd = 40695},
  {name = "More...", cmd = 41974},
}

QuickMenu(SECTION_ID.MAIN, menu_table)
