-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.dev"

local ctx = reaper.ImGui_CreateContext('text-imgui-displayer')

function loop()
  local visible, open = reaper.ImGui_Begin(ctx, 'My window', true)
  if visible then
    reaper.ImGui_Text(ctx, "Context")
    reaper.ImGui_Text(ctx, inspect({reaper.BR_GetMouseCursorContext()}))
    reaper.ImGui_Text(ctx, "Context_Envelope")
    reaper.ImGui_Text(ctx, inspect({reaper.BR_GetMouseCursorContext_Envelope()}))
    reaper.ImGui_Text(ctx, "Context_Item")
    reaper.ImGui_Text(ctx, inspect({reaper.BR_GetMouseCursorContext_Item()}))
    reaper.ImGui_Text(ctx, "Context_MIDI")
    reaper.ImGui_Text(ctx, inspect({reaper.BR_GetMouseCursorContext_MIDI()}))
    reaper.ImGui_Text(ctx, "Context_Position")
    reaper.ImGui_Text(ctx, inspect({reaper.BR_GetMouseCursorContext_Position()}))
    reaper.ImGui_Text(ctx, "Context_Take")
    reaper.ImGui_Text(ctx, inspect({reaper.BR_GetMouseCursorContext_Take()}))
    reaper.ImGui_Text(ctx, "Context_Track")
    reaper.ImGui_Text(ctx, inspect({reaper.BR_GetMouseCursorContext_Track()}))
    reaper.ImGui_End(ctx)
  end
  
  if open then
    reaper.defer(loop)
  else
    reaper.ImGui_DestroyContext(ctx)
  end
end

reaper.defer(loop)