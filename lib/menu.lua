-- functions for displaying menus easily

local actions = require "lib.actions"

-- global SECTION_ID for backwards compatibility
SECTION_ID = {
    MAIN = actions.SECTION_MAIN,
    MAIN_ALT = actions.SECTION_MAIN_ALT,
    MIDI = actions.SECTION_MIDI,
    MIDI_EVENTLIST = actions.SECTION_MIDI_EVENTLIST,
    MIDI_INLINE = actions.SECTION_MIDI_INLINE,
    EXPLORER = actions.SECTION_EXPLORER,
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

-- convert an array of table items to a menu string and a command map,
-- a table item is like this: `{name = "Color notes by pitch", cmd = 40740, check_state = false}`
function ProcessMenu(section_id, menu_table)
    local item_names = {}
    local command_map = {}
    for _, item in ipairs(menu_table) do
        local final_cmd = item.cmd
        -- if no command, replace with `false` (`nil` will cause bugs)
        if final_cmd == nil then final_cmd = false end

        local final_name = item.name
        -- add checkbox to item if it needs to be checked and is on
        if item.check_state and actions.getState(section_id, final_cmd) then
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
-- return the selected item id
function DisplayMenu(menu_str)
    gfx.init(nil, 0, 0)
    gfx.x = gfx.mouse_x
    gfx.y = gfx.mouse_y
    local item_id = gfx.showmenu(menu_str)
    gfx.quit()
    return item_id
end

-- convenience function for processing then showing a menu table
function QuickMenu(section_id, menu_table)
    local menu = ProcessMenu(section_id, menu_table)
    local menu_id = DisplayMenu(menu.str)

    if menu_id ~= 0 then
        actions.execute(section_id, menu.cmd_map[menu_id])
    end
end
