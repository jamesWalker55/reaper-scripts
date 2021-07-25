CHAR_ID = {
    ESC = 27,
    CLOSED = -1,
}

-- convert a hex color to three values between 0-255
function Color_hexToRGB(hex_num, has_alpha)
    has_alpha = has_alpha and true or false
    local r, g, b, a
    -- get alpha part first, and store remaining colors in hex_num
    if has_alpha then
        a = hex_num & 0x000000ff
        hex_num = hex_num >> 8
    else
        a = 0xff
    end

    r = (hex_num & 0xff0000) >> 16
    g = (hex_num & 0x00ff00) >> 8
    b = (hex_num & 0x0000ff)
    return r, g, b, a
end

-- convert three values between 0-255 to a hex color
function Color_RGBToHex(r, g, b)
    return (r << 16) + (g << 8) + b
end

-- -- convert a hex color to three values between 0.0-1.0
-- function Color_hexToFloats(hex_num, has_alpha)
--     local r, g, b, a = Color_hexToRGB(hex_num, has_alpha)
--     return r / 0xff, g / 0xff, b / 0xff, a / 0xff
-- end

-- convert three numbers from 0-255 to floats
function Color_RGBToFloats(r, g, b, a)
    if a == nil then
        return r / 0xff, g / 0xff, b / 0xff, 1
    else
        return r / 0xff, g / 0xff, b / 0xff, a / 0xff
    end
end

-- initialize a gfx window and return the hwnd
function GfxInitWithHwnd( ... )
    local args = {...}
    -- first arg is title, ensure it is some kind of string
    if args[1] == nil or type(args[1]) ~= "string" then args[1] = "" end

    local original_title = args[1]

    -- add a number to the end of the title so that the title is unique
    for i = 0, 65555 do
        local temp_title = original_title .. i
        local hwnd = reaper.JS_Window_Find(temp_title, true)
        if hwnd == nil then
            args[1] = temp_title
            break
        end
    end

    -- open window
    local val = gfx.init(table.unpack(args))

    -- get the hwnd using the unique title
    local hwnd = reaper.JS_Window_Find(args[1], true)

    -- rename window to original title
    if hwnd ~= nil then reaper.JS_Window_SetTitle(hwnd, original_title) end

    return val, hwnd
end
