local file = {}

-- checks if the given path is a valid file/directory
file.exists = function(path)
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

return file