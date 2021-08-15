-- this module helps you handle track state chunks like arrays

require "lib.str-funcs"

local module = {}

local function parseChunkLines(lines, start_pos)
  local i = start_pos == nil and 1 or start_pos

  local array = {}
  local array_len = 1
  while true do
    local line = lines[i]
    assert(line ~= nil, "Unexpected EOF")
    if i == start_pos then
      -- first line MUST be start of block
      array[array_len] = assert(line:match("^<(.+)"), "Parsing error")
    elseif line == ">" then
      -- reached end of block
      return array, i - start_pos
    elseif line:match("^<") then
      -- reached new block
      local subblock, lines_processed = parseChunkLines(lines, i)
      i = i + lines_processed
      array[array_len] = subblock
    else
      array[array_len] = line
    end
    i = i + 1
    array_len = array_len + 1
  end
end

module.fromString = function(chunk)
  local lines = chunk:split("\n")  -- use split instead of splitline for more efficiency
  local array = parseChunkLines(lines, 1)
  return array
end

local function arrayToChunk(arr)
  for i, val in ipairs(arr) do
    if type(val) == "table" then
      arr[i] = arrayToChunk(val)
    end
  end
  return "<" .. table.concat(arr, "\n") .. "\n>"
end

module.toString = function(array)
  return arrayToChunk(array) .. "\n"
end

-- tests the toArray and fromArray functions
module._testChunk = function(chunk)
  local chunk_copy = module.toString(module.fromString(chunk))
  return chunk == chunk_copy
end

return module
