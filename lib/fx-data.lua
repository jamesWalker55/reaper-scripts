local ini = require "lib.ini"
local file = require "lib.file"
local chunk = require "lib.chunk"

local module = {}

module._fxPathToIniKey = function(fx_path)
  local fx_name = fx_path:match([[.*[\/](.+)$]])
  local key = fx_name:gsub("[ -]", "_")
  return key
end

module.fxfolders = {
  INI_NAME = "reaper-fxfolders.ini",
}

module.fxfolders._parseFolder = function(folder_table)
  local fx_count = tonumber(folder_table["Nb"])
  if fx_count == nil then return nil, "FX count not present in folder definition" end

  local folder = {}
  for i = 1, fx_count do
    local fx_name = folder_table["Item" .. i - 1]
    if fx_name == nil then return nil, "Item " .. i .. " path missing" end

    local fx_type_num = tonumber(folder_table["Type" .. i - 1])
    if fx_type_num == nil then return nil, "Item " .. i .. " type missing" end

    local fx_type_str
    if fx_type_num == 3 then
      fx_type_str = "VST"
    elseif fx_type_num == 2 then
      fx_type_str = "JSFX"
    elseif fx_type_num == 1000 then
      fx_type_str = "FX Chain"
    else
      return nil, "Item " .. i .. " has an invalid type: " .. fx_type_num
    end

    folder[i] = {
      name = fx_name,
      type = fx_type_str,
    }
  end
  return folder
end

module.fxfolders._parseDefinition = function(folders_table)
  local folder_count = tonumber(folders_table["NbFolders"])
  if folder_count == nil then return nil, "Folder count not present in FX folders definition" end

  local folders = {}
  for i = 1, folder_count do
    local folder_name = folders_table["Name" .. i - 1]
    if folder_name == nil then return nil, "Folder " .. i .. " name missing" end

    local folder_id = folders_table["Id" .. i - 1]
    if folder_id == nil then return nil, "Folder " .. i .. " ID missing" end

    folders[i] = {
      name = folder_name,
      id = folder_id,
    }
  end
  return folders
end

--[[
  reads `reaper-fxfolders.ini` and returns a table representing the fx folder configuration.
  `ini_path` is optional
 ]]
module.fxfolders.get = function(ini_path)
  if ini_path == nil then ini_path = file.absPath(module.fxfolders.INI_NAME) end

  local fxfolder_ini, msg = ini.parseIni(ini_path, false)
  if fxfolder_ini == nil then return nil, "parseIni: " .. msg end

  local folders, msg = module.fxfolders._parseDefinition(fxfolder_ini["Folders"])
  if folders == nil then return nil, "_parseFXFolderDefinition: " .. msg end

  for _, folder in ipairs(folders) do
    local fx_ini = fxfolder_ini["Folder" .. folder.id]
    local fx_items, msg = module.fxfolders._parseFolder(fx_ini)
    if fx_items == nil then return nil, "_parseFXFolder: " .. msg end

    folder["items"] = fx_items
  end
  return folders
end

module.fxnames = {}

module.fxnames.INI_NAMES = {
  DEFAULT = "reaper-vstplugins64.ini",
  ALIAS = "reaper-vstrenames64.ini",
  JSFX = "reaper-jsfx.ini",
}

module.fxnames._getDefaultMap = function(ini_path)
  if ini_path == nil then ini_path = file.absPath(module.fxnames.INI_NAMES.DEFAULT) end

  local fxnames_ini, msg = ini.parseIni(ini_path, false)
  if fxnames_ini == nil then return nil, "parseIni: " .. msg end

  local items = nil
  -- get map from the first (and only) section
  for key, map in pairs(fxnames_ini) do
    items = map
    break
  end
  if items == nil then return nil, "Failed to obtain FX name list from " .. ini_path end

  for key, old_name in pairs(items) do
    -- remove first two values delimited by commas
    local new_name = old_name:match("%w+,[%d-]+,(.+)")
    if new_name == nil then
      -- new_name is nil if reaper fails to load a plugin, e.g. `["iZRX8De_clip.dll"]="000008231899D601"`
      -- setting value to nil will delete the key
      items[key] = nil
    else
      -- remove `!!!VSTi` text at end of some FX names
      local no_vsti = new_name:match("(.*)!!!VSTi")
      if no_vsti ~= nil then new_name = no_vsti end
      items[key] = new_name
    end
  end
  return items
end

--[[
  this can return nil if the user haven't renamed any plugins
 ]]
module.fxnames._getAliasMap = function(ini_path)
  if ini_path == nil then ini_path = file.absPath(module.fxnames.INI_NAMES.ALIAS) end

  local fxnames_ini, msg = ini.parseIni(ini_path, false)
  if fxnames_ini == nil then return nil, "parseIni: " .. msg end

  local items = nil
  -- get map from the first (and only) section
  for key, map in pairs(fxnames_ini) do
    items = map
    break
  end
  if items == nil then return nil, "Failed to obtain alias FX name list from " .. ini_path end

  for key, old_name in pairs(items) do
    -- remove `!!!VSTi` text at end of some FX names
    local no_vsti = old_name:match("(.*)!!!VSTi")
    if no_vsti ~= nil then
      items[key] = no_vsti
    end
  end
  return items
end

module.fxnames._getJSFXMap = function(ini_path)
  if ini_path == nil then ini_path = file.absPath(module.fxnames.INI_NAMES.JSFX) end

  local lines = file.lines(ini_path)
  if lines == nil then return nil, "Failed to load " .. ini_path end

  local jsfx_map = {}
  for i, line in ipairs(lines) do
    if line:find("^REV ") then
      local args = chunk.splitLine(line)
      if #args == 3 then
        local name, path = chunk.removeStringQuotes(args[2]), chunk.removeStringQuotes(args[3])
        jsfx_map[path] = name
      end
    end
  end

  return jsfx_map
end

--[[
  combined map of default names, jsfx names, and alias names
 ]]
module.fxnames.get = function()
  local default_map = module.fxnames._getDefaultMap()
  local jsfx_map = module.fxnames._getJSFXMap()
  local alias_map = module.fxnames._getAliasMap()
  for fx, name in pairs(jsfx_map) do
    assert(default_map[fx] == nil, ("Name conflict: %s is defined in default names and jsfx names"):format(fx))
    default_map[fx] = name
  end
  if alias_map ~= nil then
    for fx, name in pairs(alias_map) do
      default_map[fx] = name
    end
  end
  return default_map
end

module.fxItemMetaName = function(item, fxnames)
  if item.type == "JSFX" then
    return fxnames[item.name]
  elseif item.type == "VST" then
    local filename = item.name:match([[.*[\/](.+)$]])
    local key = filename:gsub("[^%w.]", "_")
    return fxnames[key]
  elseif item.type == "FX Chain" then
    return item.name
  else
    return nil, "Unknown item type"
  end
end

module.FX_PATH_TEMPLATE = {
  ["VST"] = "VST:%s",
  ["JSFX"] = "JS:%s",
  ["FX Chain"] = "%s.RfxChain",
  -- not tested, the following are educated guesses
  ["AU"] = "AU:%s",
  ["DX"] = "DX:%s",
}

module.fxItemToPath = function(item)
  local template = module.FX_PATH_TEMPLATE[item.type]
  if not template then return nil, "Unrecognised FX type: " .. item.type end

  return template:format(item.name)
end

return module