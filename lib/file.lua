local file = {}

-- checks if the given path is a valid file/directory
local function fileOrDirExists(path)
  path = reaper.resolve_fn2(path, "", "")
  if reaper.file_exists(path) then return true end

  -- remove trailing slashes at end of path
  while path:match([[\$]]) or path:match([[/$]]) do
    path = path:sub(1, -2)
  end

  local file, message, code = io.open(path)
  if file then
    io.close(file)
    return true
  elseif code == 13 then
    return true
  else
    return false
  end
end

-- checks if the given path is a valid file/directory
file.exists = function(path, files_only)
  if files_only then
    path = reaper.resolve_fn2(path, "", "")
    return reaper.file_exists(path)
  else
    return fileOrDirExists(path)
  end
end

file.lines = function(path)
  -- check path exists
  if not file.exists(path, true) then return nil end

  local lines = {}
  for l in io.lines(path) do
    lines[#lines + 1] = l
  end
  return lines
end

return file