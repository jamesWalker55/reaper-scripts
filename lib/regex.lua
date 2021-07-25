local regex = {}

-- escape a string for use in regex.
-- literally adds a % in front of all non-alphabet characters
-- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
regex.escape_pattern = function(text)
    return text:gsub("([^%w])", "%%%1")
end

return regex