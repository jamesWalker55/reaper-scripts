-- functions and constants for actions

local actions = {}

actions.MAIN = 0
actions.MAIN_ALT = 100
actions.MIDI = 32060
actions.MIDI_EVENTLIST = 32061
actions.MIDI_INLINE = 32062
actions.EXPLORER = 32063

-- if the input command is a string, then do a lookup
-- otherwise do nothing
actions._resolveAction = function(command)
  if type(command) ~= "string" then return command end

  return reaper.NamedCommandLookup(command)
end

-- get the on/off state of a given command
-- if command has no state, return `nil`
actions.getState = function(section_id, command_id)
  -- resolve command just in case it is a string
  command_id = actions._resolveAction(command_id)

  local state_num = reaper.GetToggleCommandStateEx(section_id, command_id)
  if state_num == -1 then return nil end

  return state_num == 1
end

-- convenience function for executing a command matching the given section_id
actions.execute = function(section_id, command_id)
  -- resolve command just in case it is a string
  command_id = actions._resolveAction(command_id)

  if section_id == actions.MAIN or section_id == actions.MAIN_ALT then
    return reaper.Main_OnCommandEx(command_id, 0, 0)
  elseif section_id == actions.MIDI or section_id == actions.MIDI_EVENTLIST or section_id == actions.MIDI_INLINE then
    return reaper.MIDIEditor_LastFocused_OnCommand(command_id, false)
  else
    error("Unknown section_id: " .. section_id)
  end
end

return actions