-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.dev"
require "lib.gui"

QUIT_SCRIPT = false

local function init()
    gfx.init("Cool window", 800, 600)
    -- set background color
    gfx.clear = Color_RGBToHex(20, 20, 20)
    -- initialize global variables
    MOUSE = {}
    MOUSE.x = gfx.mouse_x
    MOUSE.y = gfx.mouse_y
    MOUSE.cap = gfx.mouse_cap
    MOUSE._LEFT = 1  -- bitfield value of left mouse button
    MOUSE._RIGHT = 2  -- bitfield value of left mouse button
end

local function update()
    -- check for script quit status
    local char = gfx.getchar()
    if char == CHAR_ID.ESC or char == CHAR_ID.CLOSED then
        QUIT_SCRIPT = true
        return
    end
    -- update global variables
    MOUSE.prev_x = MOUSE.x
    MOUSE.prev_y = MOUSE.y
    MOUSE.prev_cap = MOUSE.cap
    MOUSE.x = gfx.mouse_x
    MOUSE.y = gfx.mouse_y
    MOUSE.cap = gfx.mouse_cap
    if MOUSE.cap then
        MOUSE.l_press = MOUSE.cap & MOUSE._LEFT == MOUSE._LEFT and MOUSE.prev_cap & MOUSE._LEFT ~= MOUSE._LEFT
        MOUSE.l_release = MOUSE.cap & MOUSE._LEFT ~= MOUSE._LEFT and MOUSE.prev_cap & MOUSE._LEFT == MOUSE._LEFT
        if MOUSE.l_press then
            MOUSE.l_press_x = MOUSE.x
            MOUSE.l_press_y = MOUSE.y
        end
        if MOUSE.l_release then
            MOUSE.l_release_x = MOUSE.x
            MOUSE.l_release_y = MOUSE.y
        end
        MOUSE.r_press = MOUSE.cap & MOUSE._RIGHT == MOUSE._RIGHT and MOUSE.prev_cap & MOUSE._RIGHT ~= MOUSE._RIGHT
        MOUSE.r_release = MOUSE.cap & MOUSE._RIGHT ~= MOUSE._RIGHT and MOUSE.prev_cap & MOUSE._RIGHT == MOUSE._RIGHT
        if MOUSE.r_press then
            MOUSE.r_press_x = MOUSE.x
            MOUSE.r_press_y = MOUSE.y
        end
        if MOUSE.r_release then
            MOUSE.r_release_x = MOUSE.x
            MOUSE.r_release_y = MOUSE.y
        end
    end
end

local function draw()
    -- check for script quit status
    if QUIT_SCRIPT then return end
    if MOUSE.l_press_x and MOUSE.l_press_y then
        gfx.set(Color_RGBToFloats(255, 0, 0, 255))  -- set pen color
        gfx.circle(MOUSE.l_press_x, MOUSE.l_press_y, 2, 1)
    end
    if MOUSE.l_release_x and MOUSE.l_release_y then
        gfx.set(Color_RGBToFloats(255, 255, 0, 255))  -- set pen color
        gfx.circle(MOUSE.l_release_x, MOUSE.l_release_y, 2, 1)
    end
    if MOUSE.r_press_x and MOUSE.r_press_y then
        gfx.set(Color_RGBToFloats(0, 255, 255, 255))  -- set pen color
        gfx.circle(MOUSE.r_press_x, MOUSE.r_press_y, 2, 1)
    end
    if MOUSE.r_release_x and MOUSE.r_release_y then
        gfx.set(Color_RGBToFloats(0, 0, 255, 255))  -- set pen color
        gfx.circle(MOUSE.r_release_x, MOUSE.r_release_y, 2, 1)
    end
    gfx.set(Color_RGBToFloats(200, 200, 200, 255))
    gfx.line(10, 10, 80, 120)
    gfx.rect(200, 200, 200, 200, 0)
    gfx.roundrect(250, 420, 200, 50, 10)
    gfx.update()
end

local function mainLoop()
    update()
    draw()
    if not QUIT_SCRIPT then
        reaper.defer(mainLoop)
    end
end

init()
reaper.defer(mainLoop)
