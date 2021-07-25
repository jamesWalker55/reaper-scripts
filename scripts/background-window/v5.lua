local imgui_context = reaper.ImGui_CreateContext('bg-window')
local imgui_viewport = reaper.ImGui_GetMainViewport(imgui_context)
local hwnd_main = reaper.GetMainHwnd()
-- local hwnd_imgui = reaper.ImGui_GetNativeHwnd(imgui_context)

function Unfocus()
    -- -- setting zorder also sets focus
    -- reaper.JS_Window_SetZOrder(hwnd_imgui, "INSERTAFTER", hwnd_main)
    -- set focus to main instead
    reaper.BR_Win32_SetFocus(hwnd_main)
end

function Loop()
    -- reaper.ImGui_SetNextWindowPos(imgui_context, reaper.ImGui_Viewport_GetPos(imgui_viewport))
    -- reaper.ImGui_SetNextWindowSize(imgui_context, reaper.ImGui_Viewport_GetSize(imgui_viewport))

    local visible, open = reaper.ImGui_Begin(
        imgui_context,
        'Background Window',
        true,
        reaper.ImGui_WindowFlags_NoBringToFrontOnFocus() | reaper.ImGui_WindowFlags_NoDocking() | reaper.ImGui_WindowFlags_NoFocusOnAppearing()
    )
    -- if reaper.ImGui_IsWindowFocused(imgui_context) then Unfocus() end
    if visible then reaper.ImGui_End(imgui_context) end


    -- if reaper.BR_Win32_GetForegroundWindow() == hwnd_imgui then Unfocus() end

    if open then
        reaper.defer(Loop)
    else
        reaper.ImGui_DestroyContext(imgui_context)
    end
end

Loop()
