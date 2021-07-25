-- boiler code to override reaper search paths
local parent_dir =
    ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.dev"

NULL = "0"

function SimpleFindWindowEx(parent_hwnd, prev_hwnd, class_string, name_string,
                            match_class, match_name)
    assert(parent_hwnd ~= NULL, "You cannot use " .. NULL .. " as parent_hwnd!")
    assert(prev_hwnd ~= NULL, "You cannot use " .. NULL .. " as prev_hwnd!")
    assert(class_string ~= NULL,
           "You cannot use " .. NULL .. " as class_string!")
    assert(name_string ~= NULL, "You cannot use " .. NULL .. " as name_string!")

    if parent_hwnd == nil then
        parent_hwnd = NULL
    else
        parent_hwnd = reaper.BR_Win32_HwndToString(parent_hwnd)
    end

    if prev_hwnd == nil then
        prev_hwnd = NULL
    else
        prev_hwnd = reaper.BR_Win32_HwndToString(prev_hwnd)
    end

    if class_string == nil then class_string = NULL end
    if name_string == nil then name_string = NULL end

    return reaper.BR_Win32_FindWindowEx(parent_hwnd, prev_hwnd, class_string,
                                        name_string, match_class, match_name)
end

function GetChildHwnds(parent_hwnd)
    if parent_hwnd == nil then parent_hwnd = reaper.GetMainHwnd() end
    local hwnds = {}
    while true do
        local prev_hwnd = hwnds[#hwnds]
        local hwnd = SimpleFindWindowEx(parent_hwnd, prev_hwnd, nil, nil, false,
                                        false)
        if hwnd then
            table.insert(hwnds, hwnd)
        else
            return hwnds
        end
    end
end

function GetHwndsRecursive(parent_hwnd)
    local hwnds = GetChildHwnds(parent_hwnd)
    for _, hwnd in ipairs(hwnds) do
        local child_hwnds = GetChildHwnds(hwnd)
        for _, c_hwnd in ipairs(child_hwnds) do
            table.insert(hwnds, c_hwnd)
        end
    end
    return hwnds
end
