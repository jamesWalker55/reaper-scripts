local function p(x)
    if x == "" then x = " " end
    reaper.ShowConsoleMsg(x)
    reaper.ShowConsoleMsg("\n")
end

local function getCommandState(section_id, command_id)
    local state_num = reaper.GetToggleCommandStateEx(section_id, command_id)
    if state_num == -1 then error("Command does not have a state!") end
    return state_num == 1
end

-- checks if the MIDI channel has a certain state
local function MIDIChannelStates()
    local MIDI_SECTION_ID = 32060
    local soloCmdStart = 40218
    local visibleCmdStart = 40643
    local editableCmdStart = 40482

    local states = {
        solo = {},
        visible = {},
        editable = {},
    }
    local noneVisible = true
    
    for ch = 1, 16 do
        local isSolo, isVisible, isEditable, msg
        isSolo = getCommandState(MIDI_SECTION_ID, soloCmdStart + ch - 1)
        isVisible = getCommandState(MIDI_SECTION_ID, visibleCmdStart + ch - 1)
        isEditable = getCommandState(MIDI_SECTION_ID, editableCmdStart + ch - 1)
        if isVisible then noneVisible = false end
        table.insert(states.solo, isSolo)
        table.insert(states.visible, isVisible)
        table.insert(states.editable, isEditable)
    end

    states.allVisible = noneVisible
    return states
end

local function test()
    reaper.ShowConsoleMsg("")
    local states = MIDIChannelStates()
    p("All channels visible: " .. (states.allVisible and "TRUE" or "no"))
    for i = 1, 16 do
        local isSolo, isVisible, isEditable, msg
        isSolo = states.solo[i]
        isVisible = states.visible[i]
        isEditable = states.editable[i]
        msg = "Channel " .. i
        if isSolo then msg = msg .. " SOLO" end
        if isVisible then msg = msg .. " visible" end
        if isEditable then msg = msg .. " EDITABLE" end
        p(msg)
    end
    reaper.defer(test)
end

test()