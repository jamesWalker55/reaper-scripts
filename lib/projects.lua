local projects = {}

--[[
Without arguments: Get the active Reaper project

With arguments: Get the Reaper project at the tab index (index from 1)
]]
projects.get = function(tab_id)
	if tab_id == nil then
    	return reaper.EnumProjects(-1)
	else
    	return reaper.EnumProjects(tab_id - 1)
	end
end

--[[
iterator that returns all loaded projects in Reaper. Index starts at 1.

    for i, proj, path in api.iterProjects() do print(i, proj, path) end
]]
projects.iter = function()
	local function iter(_, i)
		i = i + 1
		local proj, path = reaper.EnumProjects(i - 1)
		if proj then
			return i, proj, path
		end
	end
	return iter, nil, 0
end

--[[
return an array of all projects in reaper
]]
projects.all = function()
	local projs = {}
	local i = 0
	while true do
		local projTable = {reaper.EnumProjects(i)}
		if projTable[1] == nil then break end

		table.insert(projs, projTable)
		i = i + 1
	end
	return projs
end

return projects