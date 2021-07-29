-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
  {name = "#Show take envelopes..."},
  {name = "Volume envelope", cmd = "_S&M_TAKEENVSHOW9"},
  {name = "Pan envelope", cmd = "_S&M_TAKEENVSHOW10"},
  {name = "Pitch envelope", cmd = "_S&M_TAKEENVSHOW12"},
  {name = "Mute envelope", cmd = "_S&M_TAKEENVSHOW11"},
  {name = ""},
  {name = "#Bypass take envelopes..."},
  {name = "Volume envelope", cmd = "_S&_S&M_TAKEENV4"},
  {name = "Pan envelope", cmd = "_S&_S&M_TAKEENV5"},
  {name = "Pitch envelope", cmd = "_S&_S&M_TAKEENV11"},
  {name = "Mute envelope", cmd = "_S&_S&M_TAKEENV6"},
  {name = ""},
  {name = "More...", cmd = 41974},
}

QuickMenu(SECTION_ID.MAIN, menu_table)