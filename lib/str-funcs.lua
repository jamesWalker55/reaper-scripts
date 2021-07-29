-- https://stackoverflow.com/questions/1426954/split-string-in-lua
string.split = function(input, separator)
  if separator == nil then separator = "%s" end
  local t = {}
  for match in string.gmatch(input, "([^" .. separator .. "]+)") do
    table.insert(t, match)
  end
  return t
end
