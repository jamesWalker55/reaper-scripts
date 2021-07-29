-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

local actions = require "lib.actions"
require "lib.menu"

-- check if multiple notes are selected in the active MIDI window
function MultipleSelected()
  -- Get HWND, then current take
  local hwnd = reaper.MIDIEditor_GetActive()
  local take = reaper.MIDIEditor_GetTake(hwnd)

  -- get notes count
  local _, notes, _, _ = reaper.MIDI_CountEvts(take)

  local atLeastOneSelected = false

  for i = 0, notes - 1 do
    local _, selected, _, _, _, _, _, _ = reaper.MIDI_GetNote(take, i)
    if selected == true then -- find which notes are selected
      if atLeastOneSelected then
        return true
      else
        atLeastOneSelected = true
      end
    end
  end
  return false
end

local menu_table

if MultipleSelected() then
  menu_table = {
    {name = "#Flip selected notes..."},
    {name = "Vertically", cmd = 40908},
    {name = "Vertically (preserving pitch)", cmd = 40906},
    {name = "Horizontally", cmd = 40902},
    {name = ""},
    {name = "#Other transformations"},
    {name = "Join notes", cmd = 40456},
    {name = "Legato notes", cmd = 40765},
    {name = "Legato notes (Relative note spacing)", cmd = 40766},
    {name = ""},
    {name = "#Muting"},
    {name = "Toggle mute events", cmd = 40055},
    {name = "Mute events", cmd = 40057},
    {name = "Unmute events", cmd = 40058},
    {name = ""},
    {name = "#Arpeggiate selected notes (KAWA)"},
    {name = "Ascending", cmd = "_kawa_MIDI2_GenerateArpeggio"},
    {name = "Random", cmd = "_kawa_MIDI2_GenerateRandomArpeggio"},
    {name = ""},
    {name = "#Detect from selected notes... (KAWA)"},
    {name = ">Top Notes"},
    {name = "Select", cmd = "_kawa_MIDI2_Select_TopNotes"},
    {name = "Select (Near detection)", cmd = "_kawa_MIDI2_Select_TopNotes_Near"},
    {name = "Extract", cmd = "_kawa_MIDI2_Extract_TopNotes"},
    {name = "Extract (Near detection)", cmd = "_kawa_MIDI2_Extract_TopNotes_Near"},
    {name = "Delete", cmd = "_kawa_MIDI2_Delete_TopNotes"},
    {name = "<Delete (Near detection)", cmd = "_kawa_MIDI2_Delete_TopNotes_Near"},
    {name = ">Bass Notes"},
    {name = "Select", cmd = "_kawa_MIDI2_Select_BassNotes"},
    {name = "Select (Near detection)", cmd = "_kawa_MIDI2_Select_BassNotes_Near"},
    {name = "Extract", cmd = "_kawa_MIDI2_Extract_BassNotes"},
    {name = "Extract (Near detection)", cmd = "_kawa_MIDI2_Extract_BassNotes_Near"},
    {name = "Delete", cmd = "_kawa_MIDI2_Delete_BassNotes"},
    {name = "<Delete (Near detection)", cmd = "_kawa_MIDI2_Delete_BassNotes_Near"},
    -- this should be in its own menu, for exploding notes into other items/tracks/etc
    -- {name = ""},
    -- {name = "#Explode selected notes into items... (KAWA)"},
    -- {name = "By pitch", cmd = "_kawa_MIDI2_ExplodeSelectedNote_Type2"},
    {name = ""},
    {name = "#Set note length without overlapping notes... (KAWA)"},
    {name = "To half", cmd = "_kawa_MIDI2_NoteLength_ToHalf"},
    {name = "To double", cmd = "_kawa_MIDI2_NoteLength_ToDouble"},
    {name = "To end of bar", cmd = "_kawa_MIDI2_NoteLength_ToEndOfBar"},
    {name = "To end of take", cmd = "_kawa_MIDI2_NoteLength_ToEndOfTake"},
  }
else
  menu_table = {
    {name = "#Flip all notes..."},
    {name = "Flip vertically", cmd = 40907},
    {name = "Flip vertically (preserving pitch)", cmd = 40905},
    {name = "Flip horizontally", cmd = 40019},
    {name = ""},
    {name = "#Other transformations"},
    {name = "Join notes", cmd = 40456},
    {name = "Legato notes", cmd = 40765},
    {name = "Legato notes (Relative note spacing)", cmd = 40766},
    {name = ""},
    {name = "#Muting"},
    {name = "Toggle mute events", cmd = 40055},
    {name = "Mute events", cmd = 40057},
    {name = "Unmute events", cmd = 40058},
    {name = ""},
    {name = "#Arpeggiate all notes (KAWA)"},
    {name = "Ascending", cmd = "_kawa_MIDI2_GenerateArpeggio"},
    {name = "Random", cmd = "_kawa_MIDI2_GenerateRandomArpeggio"},
    {name = ""},
    {name = "#Detect from all notes... (KAWA)"},
    {name = ">Top Notes"},
    {name = "Select", cmd = "_kawa_MIDI2_Select_TopNotes"},
    {name = "Select (Near detection)", cmd = "_kawa_MIDI2_Select_TopNotes_Near"},
    {name = "Extract", cmd = "_kawa_MIDI2_Extract_TopNotes"},
    {name = "Extract (Near detection)", cmd = "_kawa_MIDI2_Extract_TopNotes_Near"},
    {name = "Delete", cmd = "_kawa_MIDI2_Delete_TopNotes"},
    {name = "<Delete (Near detection)", cmd = "_kawa_MIDI2_Delete_TopNotes_Near"},
    {name = ">Bass Notes"},
    {name = "Select", cmd = "_kawa_MIDI2_Select_BassNotes"},
    {name = "Select (Near detection)", cmd = "_kawa_MIDI2_Select_BassNotes_Near"},
    {name = "Extract", cmd = "_kawa_MIDI2_Extract_BassNotes"},
    {name = "Extract (Near detection)", cmd = "_kawa_MIDI2_Extract_BassNotes_Near"},
    {name = "Delete", cmd = "_kawa_MIDI2_Delete_BassNotes"},
    {name = "<Delete (Near detection)", cmd = "_kawa_MIDI2_Delete_BassNotes_Near"},
    -- {name = ""},
    -- {name = "#Explode notes into items... (KAWA)"},
    -- {name = "By pitch", cmd = "_kawa_MIDI2_ExplodeSelectedNote_Type2"},
    {name = ""},
    {name = "#Set note length without overlapping notes... (KAWA)"},
    {name = "To half", cmd = "_kawa_MIDI2_NoteLength_ToHalf"},
    {name = "To double", cmd = "_kawa_MIDI2_NoteLength_ToDouble"},
    {name = "To end of bar", cmd = "_kawa_MIDI2_NoteLength_ToEndOfBar"},
    {name = "To end of take", cmd = "_kawa_MIDI2_NoteLength_ToEndOfTake"},
  }
end

QuickMenu(SECTION_ID.MAIN, menu_table)
