local file = {}

file.exists = function(path)
    path = reaper.resolve_fn2(path, "", "")
    local file, message, code = io.open(path)
    if file then
        return true
    elseif code == 13 then
        return true
    else
        return false
    end
end

return file