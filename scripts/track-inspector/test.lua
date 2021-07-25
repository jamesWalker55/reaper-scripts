-- boiler code to override reaper search paths
local parent_dir =
    ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.dev"


reaper.defer(function()
    Ctx = reaper.ImGui_CreateContext('Simple Track Inspector', 300, 500)
    Viewport = reaper.ImGui_GetMainViewport(Ctx)
    Click_count, Text = 0, 'hello dear imgui'
    Loop()
end)

function FrameMain()
    -- the viewport is the base container itself
    -- for the next imgui window created, resize the window to the container
    reaper.ImGui_SetNextWindowPos(Ctx, reaper.ImGui_Viewport_GetPos(Viewport))
    reaper.ImGui_SetNextWindowSize(Ctx, reaper.ImGui_Viewport_GetSize(Viewport))

    reaper.ImGui_Begin(Ctx, 'wnd', nil, reaper.ImGui_WindowFlags_NoDecoration())

    if reaper.ImGui_Button(Ctx, 'Click me!') then
        Click_count = Click_count + 1
    end

    if Click_count % 2 == 1 then
        reaper.ImGui_SameLine(Ctx)
        reaper.ImGui_Text(Ctx, [[\o/]])
    end

    rv, Text = reaper.ImGui_InputText(Ctx, 'text input', Text)

    reaper.ImGui_End(Ctx)
end

function FrameFX()
    if reaper.ImGui_Button(Ctx, 'Click me!') then
        Click_count = Click_count + 1
    end

    if Click_count % 2 == 1 then
        reaper.ImGui_SameLine(Ctx)
    end

    rv, Text = reaper.ImGui_InputText(Ctx, 'text input', Text)
end

function Loop()
    local rv

    if reaper.ImGui_IsCloseRequested(Ctx) then
        reaper.ImGui_DestroyContext(Ctx)
        return
    end

    FrameMain()

    -- loop!
    reaper.defer(Loop)
end
