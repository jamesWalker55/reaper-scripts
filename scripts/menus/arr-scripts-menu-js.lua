-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. '?.lua'
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. '?.lua'
package.path = _parent_path .. ';' .. _root_path

require "lib.dev"
require "lib.str-funcs"
require "lib.menu"

local act = require "lib.actions"
local config = require "lib.config"

function ScriptActions(section_id)
  local scripts = {}

  local action_idx = 0
  local command_id, name
  while command_id ~= 0 do
    command_id, name = reaper.CF_EnumerateActions(section_id, action_idx)
    if name:match("^Script: ") then
      local name_without_script = name:match("^Script: (.+)$")
      local final_dot_pos = ({name_without_script:find("%.[^%.]*$")})[1]
      local name_without_extension = name_without_script:sub(0, final_dot_pos - 1)
      table.insert(scripts, {cmd=command_id, name=name_without_extension})
    end
    action_idx = action_idx + 1
  end

  return scripts
end

-- actions is a list of {cmd=112312, name="adsadsadsa"} tables
-- blacklist is a list of strings
function FilterActions(actions, blacklist)
  local filtered_actions = {}

  for _, action in ipairs(actions) do
    local allowed = true
    for _, word in ipairs(blacklist) do
      if action.name:find(word, nil, true) then
        allowed = false
        break
      end
    end
    if allowed then table.insert(filtered_actions, action) end
  end

  return filtered_actions
end

function SetBlacklist()
  local ok, blacklist = reaper.GetUserInputs("Edit blacklist", 1, "Use '|' to separate each item,extrawidth=400", config.val.arr_menu_blacklist or "")
  if not ok then return end

  config.val.arr_menu_blacklist = blacklist
end

function Main()
  local actions = ScriptActions(act.MAIN)

  -- filter actions if blacklist exists
  if config.val.arr_menu_blacklist ~= nil then
    local blacklist = config.val.arr_menu_blacklist:split("|")
    actions = FilterActions(actions, blacklist)
  end

  table.insert(actions, 1, {name = ""})
  table.insert(actions, 1, {name = "Blacklist..."})

  local section = act.MAIN

  local menu = ProcessMenu(section, actions)
  local menu_id = DisplayMenu(menu.str)

  if menu_id == 1 then
    SetBlacklist()
  elseif menu_id ~= 0 then
    act.execute(section, menu.cmd_map[menu_id])
  end
end

Main()
