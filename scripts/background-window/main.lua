local ctx = reaper.ImGui_CreateContext('My script')

function loop()
  local visible, open = reaper.ImGui_Begin(
      ctx,
      'My window',
      true,
      reaper.ImGui_WindowFlags_NoBringToFrontOnFocus() | reaper.ImGui_WindowFlags_NoDocking() | reaper.ImGui_WindowFlags_NoFocusOnAppearing()
    )
  if visible then
    reaper.ImGui_Text(ctx, 'Hello World!')
    reaper.ImGui_End(ctx)
  end
  
  if open then
    reaper.defer(loop)
  else
    reaper.ImGui_DestroyContext(ctx)
  end
end

reaper.defer(loop)