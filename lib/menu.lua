-- functions and constants for menus and actions

SECTION_ID = {
    MAIN = 0,
    MAIN_ALT = 100,
    MIDI = 32060,
    MIDI_EVENTLIST = 32061,
    MIDI_INLINE = 32062,
    EXPLORER = 32063,
}

-- given the menu and the item number, return the name of the menu item the user clicked on
function GetMenuItem(menu, item_id)
    reaper.ShowConsoleMsg("")
    local i = 1
    for item in string.gmatch(menu, "[^|]*") do
        local first_letter = string.sub(item, 1, 1)
        if not (first_letter == ">" or first_letter == "") then
            if i == item_id then
                return string.match(item, "[^><!#].*")
            end
            i = i + 1
        end
    end
end

-- get the on/off state of a given command
-- if command has no state, return `nil`
function GetCommandState(section_id, command_id)
    local state_num = reaper.GetToggleCommandStateEx(section_id, command_id)
	if state_num == -1 then
    	return nil
	else
    	return state_num == 1
	end
end

-- convert an array of table items to a menu string and a command map,
-- a table item is like this: `{name = "Color notes by pitch", cmd = 40740, check_state = false}`
function ProcessMenu(section_id, menu_table)
    local item_names = {}
    local command_map = {}
    for _, item in ipairs(menu_table) do
        local final_cmd = item.cmd
        -- handle named commands
        if type(final_cmd) == "string" then final_cmd = reaper.NamedCommandLookup(final_cmd) end
        -- if no command, replace with `false` (`nil` will cause bugs)
        if final_cmd == nil then final_cmd = false end

        local final_name = item.name
        -- add checkbox to item if it needs to be checked and is on
        if item.check_state and GetCommandState(section_id, final_cmd) then
            final_name = "!" .. final_name
        end

        table.insert(item_names, final_name)
        local first_letter = string.sub(item.name, 1, 1)
        if not (first_letter == ">" or first_letter == "") then
            table.insert(command_map, final_cmd)
        end
    end
    local menu_str = table.concat(item_names, "|")
    return {str = menu_str, cmd_map = command_map}
end

-- display a menu given the menu string
function DisplayMenu(menu_str)
    gfx.init(nil, 0, 0)
    gfx.x = gfx.mouse_x
    gfx.y = gfx.mouse_y
    local item_id = gfx.showmenu(menu_str)
    gfx.quit()
    return item_id
end

-- convenience function for executing a command matching the given section_id
local function executeCommand(section_id, command_id)
    if section_id == SECTION_ID.MAIN or section_id == SECTION_ID.MAIN_ALT or section_id == SECTION_ID.EXPLORER then
        reaper.Main_OnCommand(command_id, 0)
    else
        reaper.MIDIEditor_LastFocused_OnCommand(command_id, false)
    end
end

-- convenience function for processing then showing a menu table
function QuickMenu(section_id, menu_table)
    local menu = ProcessMenu(section_id, menu_table)
    local menu_id = DisplayMenu(menu.str)

    if menu_id ~= 0 then
        executeCommand(section_id, menu.cmd_map[menu_id])
    end
end
