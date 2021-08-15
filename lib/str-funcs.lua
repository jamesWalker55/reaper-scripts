string.split = function(text, separator)
  local items = {}
  local i = 1
  local search_pos = 0
  while true do
    local match_pos = text:find(separator, search_pos + 1, true)
    if match_pos == nil then
      -- if no match, then it is end of string
      items[i] = text:sub(search_pos + 1, -1)
      return items
    else
      -- split the text at that point
      items[i] = text:sub(search_pos + 1, match_pos - 1)
      i = i + 1
      search_pos = match_pos
  end
  end
end
