-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"
local act = require "lib.actions"

-- various action ids
ACTION_ID = {
    SOLO_START = 40218,
    VISIBLE_START = 40643,
    VISIBLE_ALL = 40217,
    EDITABLE_START = 40482,
}

-- position of item in menu
MENU_POS = {
    EDITABLE_START = 2,
    VISIBLE_START = 20,
    VISIBLE_ALL = 19,
    SOLO_START = 36,
}

-- get the channel being edited
local function getEditingChannel()
    local hwnd = reaper.MIDIEditor_GetActive()
    local channel = reaper.MIDIEditor_GetSetting_int(hwnd, "default_note_chan") + 1
    return channel
end

-- return 3 arrays representing the state of each channel, and 1 boolean representing whether all channels are visible
local function MIDIChannelStates()
    local states = {
        solo = {},
        visible = {},
        editable = {},
        allVisible = true,
    }

    local editingChannel = getEditingChannel()

    for ch = 1, 16 do
        local isSolo, isVisible, isEditable
        isSolo = act.getState(SECTION_ID.MIDI, ACTION_ID.SOLO_START + ch - 1)
        isVisible = act.getState(SECTION_ID.MIDI, ACTION_ID.VISIBLE_START + ch - 1)
        isEditable = ch == editingChannel
        if isVisible then states.allVisible = false end
        table.insert(states.solo, isSolo)
        table.insert(states.visible, isVisible)
        table.insert(states.editable, isEditable)
    end
    return states
end

local function generateChannelMenu()
    local function insertMenuItem(menu, name, prefix)
        table.insert(menu, prefix .. name)
    end

    local is = MIDIChannelStates()
    local menuEdit = { "#Set editable channel" }
    local menuVisible = { "#Set channel visibility" }
    local menuSolo = { ">Show single channel..." }

    insertMenuItem(menuVisible, "Show all channels", (is.allVisible and "!" or "" ))

    for ch = 1, 16 do
        insertMenuItem(menuEdit, "Edit channel " .. ch, (is.editable[ch] and "!" or "" ))

        insertMenuItem(menuVisible, "Channel " .. ch, (is.visible[ch] and "!" or "" ))

        local soloPrefix = ""
        if is.solo[ch] then soloPrefix = "!" .. soloPrefix end
        if ch == 16 then soloPrefix = "<" .. soloPrefix end
        insertMenuItem(menuSolo, "Channel " .. ch, soloPrefix)
    end

    local menuEditStr = table.concat(menuEdit, "|")
    local menuVisibleStr = table.concat(menuVisible, "|")
    local menuSoloStr = table.concat(menuSolo, "|")
    return menuEditStr .. "||" .. menuVisibleStr .. "||" .. menuSoloStr
end

local function menuIDToCommand(menu_id)
    if MENU_POS.EDITABLE_START <= menu_id and menu_id <= MENU_POS.EDITABLE_START + 15 then
        return menu_id - MENU_POS.EDITABLE_START + ACTION_ID.EDITABLE_START
    elseif MENU_POS.VISIBLE_START <= menu_id and menu_id <= MENU_POS.VISIBLE_START + 15 then
        return menu_id - MENU_POS.VISIBLE_START + ACTION_ID.VISIBLE_START
    elseif MENU_POS.SOLO_START <= menu_id and menu_id <= MENU_POS.SOLO_START + 15 then
        return menu_id - MENU_POS.SOLO_START + ACTION_ID.SOLO_START
    elseif menu_id == MENU_POS.VISIBLE_ALL then
        return ACTION_ID.VISIBLE_ALL
    else
        error("Invalid item selected!")
    end
end

local selected_id = DisplayMenu(generateChannelMenu())

if selected_id ~= 0 then
    local command_id = menuIDToCommand(selected_id)
    reaper.MIDIEditor_LastFocused_OnCommand(command_id, false)
end
