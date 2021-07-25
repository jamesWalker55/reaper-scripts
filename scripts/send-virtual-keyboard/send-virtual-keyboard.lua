-- keeps calling ACTION_SEND_TO_VKB until its state is on, then stops
-- set this as the SWS global startup action

MAIN_SECTION_ID = 0
ACTION_SEND_TO_VKB = 40637

-- get the on/off state of a given command
-- if command has no state, return `nil`
function GetMainCommandState(command_id)
    local state_num = reaper.GetToggleCommandStateEx(0, command_id)
	if state_num == -1 then
    	return nil
	else
    	return state_num == 1
	end
end

-- get enabled state of ACTION_SEND_TO_VKB
function KeyboardToVKBIsEnabled()
    return GetMainCommandState(ACTION_SEND_TO_VKB)
end

-- enable ACTION_SEND_TO_VKB
function ToggleKeyboardToVKB()
    reaper.Main_OnCommand(ACTION_SEND_TO_VKB, 0)
end

function Loop()
    if not KeyboardToVKBIsEnabled() then
        ToggleKeyboardToVKB()
        reaper.defer(Loop)
    end
end

reaper.defer(Loop)
