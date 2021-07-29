-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
  {name = "Explode notes to new item", cmd = "_kawa_MIDI2_SelectedNotes_ToNewMediaItem"},
  {name = "Explode notes to new track", cmd = "_kawa_MIDI2_SelectedNotes_ToNewTrack"},
  {name = "Explode notes to items by pitch", cmd = "_kawa_MIDI2_ExplodeSelectedNote_Type2"},
}

QuickMenu(SECTION_ID.MIDI, menu_table)
