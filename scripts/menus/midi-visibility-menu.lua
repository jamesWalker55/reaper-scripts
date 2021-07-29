-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. '?.lua'
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. '?.lua'
package.path = _parent_path .. ';' .. _root_path

require "lib.menu"

local menu_table = {
  {name = "#Panels"},
  {name = "Track list", cmd = 40818, check_state=true},
  {name = "Media item lane", cmd = 40819, check_state=true},
  {name = ""},
  {name = "#Show in piano roll..."},
  {name = "Notation text on notes", cmd = 42101, check_state=true},
  {name = "Note names", cmd = 40045, check_state=true},
  {name = "Velocity handles", cmd = 40040, check_state=true},
  {name = "Velocity numbers", cmd = 40632, check_state=true},
  {name = "Tempo/Time signature markers", cmd = 40953, check_state=true},
  {name = ""},
  {name = "#Display/Hide note rows"},
  {name = "Show all rows", cmd = 40452, check_state=true},
  {name = "Hide rows without notes", cmd = 40453, check_state=true},
  {name = "Hide rows without notes or names", cmd = 40454, check_state=true},
}


QuickMenu(SECTION_ID.MIDI, menu_table)
