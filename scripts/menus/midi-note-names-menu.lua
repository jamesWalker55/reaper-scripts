-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. '?.lua'
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. '?.lua'
package.path = _parent_path .. ';' .. _root_path

require "lib.menu"

local menu_table = {
  {name = "List note/CC name files...", cmd = 40915},
  {name = "Rename Current note", cmd = 40411},
  {name = ""},
  {name = "#MIDI Note/CC Names"},
  {name = "Save to file...", cmd = 40410},
  {name = "Load from file...", cmd = 40409},
  {name = "Clear all", cmd = 40412},
  {name = ""},
  {name = "#Settings"},
  {name = "Show note names", cmd = 40045, check_state=true},
  {name = "Note name actions only apply to the active channel", cmd = 40955, check_state=true},
  {name = "Show all note rows", cmd = 40452, check_state=true},
  {name = "Hide note rows without notes or names", cmd = 40454, check_state=true},
}


QuickMenu(SECTION_ID.MIDI, menu_table)
