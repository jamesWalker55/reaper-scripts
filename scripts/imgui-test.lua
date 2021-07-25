-- boiler code to override reaper search paths
local parent_dir =
    ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.dev"
require "lib.gui"

reaper.defer(function()
    Ctx = reaper.ImGui_CreateContext('My script', 300, 60)
    Viewport = reaper.ImGui_GetMainViewport(Ctx)
    Click_count, Text = 0, 'hello dear imgui'
    Loop()
end)

function Frame()
    if reaper.ImGui_Button(Ctx, 'Click me!') then
        Click_count = Click_count + 1
    end

    if Click_count % 2 == 1 then
        reaper.ImGui_SameLine(Ctx)
        reaper.ImGui_Text(Ctx, [[\o/]])
    end

    rv, Text = reaper.ImGui_InputText(Ctx, 'text input', Text)
    clear()
    p({rv, Text})
end

function Loop()
    local rv

    if reaper.ImGui_IsCloseRequested(Ctx) then
        reaper.ImGui_DestroyContext(Ctx)
        return
    end

    -- the viewport is the base container itself
    -- for the next imgui window created, resize the window to the container
    reaper.ImGui_SetNextWindowPos(Ctx, reaper.ImGui_Viewport_GetPos(Viewport))
    reaper.ImGui_SetNextWindowSize(Ctx, reaper.ImGui_Viewport_GetSize(Viewport))

    -- create a window context, and give it a NoDecoration() flag
    reaper.ImGui_Begin(Ctx, 'wnd', nil, reaper.ImGui_WindowFlags_NoDecoration())
    -- populate the window with widgets and shit
    Frame()
    -- end the window context
    reaper.ImGui_End(Ctx)

    -- loop!
    reaper.defer(Loop)
end
