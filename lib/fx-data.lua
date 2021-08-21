local ini = require "lib.ini"
local file = require "lib.file"

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

return module