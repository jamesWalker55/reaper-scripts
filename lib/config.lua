local SECTION = "kotll Scripts"

-- sets a setting, key and value must be strings
-- persist lets the value persist after exiting reaper
local function configSet(key, value, permanent)
    assert(type(value) == "string", "only strings may be stored in extended state! (input type is " .. type(value) .. ")")
    -- setting is permanent by default
    if permanent == nil then permanent = true end
    reaper.SetExtState(SECTION, key, value, permanent)
end

-- gets a setting, key must be a string
local function configGet(key)
    return reaper.GetExtState(SECTION, key)
end

-- deletes a setting, key must be a string
local function configDel(key, permanent)
    -- delete setting permanently by default
    if permanent == nil then permanent = true end
    reaper.DeleteExtState(SECTION, key, permanent)
end

-- checks if a setting exists, key must be a string
local function configExists(key)
    return reaper.HasExtState(SECTION, key)
end

--[[
config variable
```
config = require "lib.config"

-- standard operations
config.has_key("cool_key") == false

config.set("cool_key", "hello")

config.get("cool_key") == "hello"
config.has_key("cool_key") == true

config.del("cool_key")
config.has_key("cool_key") == false

-- using val shorthand
config.has_key("cool_key") == false

config.val.cool_key = "hello"

config.val.cool_key == "hello"
config.has_key("cool_key") == true

config.val.cool_key = nil
config.has_key("cool_key") == false
```
 ]]
local config = {
    has_key = configExists,
    set = configSet,
    get = configGet,
    del = configDel,
    val = {},
}

local config_metatable = {
    -- access config with `config.val.KEY_NAME`
    __index = function(table, key)
        if configExists(key) then
            return configGet(key)
        else
            error("The key '" .. key .. "' does not exist in the extended state!")
        end
    end,

    -- set config with `config.val.KEY_NAME = VALUE` ;
    -- delete a config with `config.val.KEY_NAME = nil`
    __newindex = function(table, key, val)
        if val == nil then
            configDel(key)
        else
            configSet(key, val)
        end
    end
}

setmetatable(config.val, config_metatable)

return config