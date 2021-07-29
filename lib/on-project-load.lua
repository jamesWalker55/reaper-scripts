--[[
this is a callback handler that tries to check if a new project has been loaded

known missed cases:
- loading the same project again in the same tab when the project is undirty

this should cover all project loading cases, but there are non-loading cases where it will also fire:
- Saving a project to a new path
]]


local projectLoadCallback = {}

-- Tab id. This isn't actually a tab id, it's the project memory
-- address, but it functions as the tab id in this use case
local function tabId(project)
  return tostring(project):match("^userdata: (.+)$")
end

-- start of detection code

local prev_projects = {}
local callbacks = {}
local exitCallbacks = {}
local exit = false

local function loop()
  local current_projects = {}
  local i = 0

  while true do
    -- iterate through each project until end
    local proj, path = reaper.EnumProjects(i)
    if proj == nil then break end

    -- basic id for identifying tab-project pair
    local tab_proj_id = tabId(proj) .. path

    -- save is-dirty data
    -- also used as "project exists" indicator, just check if it ~= nil
    current_projects[tab_proj_id] = { is_dirty = reaper.IsProjectDirty(proj) ~= 0 }

    -- check if this is a new project, skip callbacks otherwise
    -- conditions for skipping callbacks (treat as existing project):
    -- 1. project with same tab_proj_id existed last round, and...
    -- 2. a new empty project is created in a tab which already had an unsaved project
    --     2a. current project has empty path, is unsaved
    --     2b. current project is undirty, but previous project is dirty
    if prev_projects[tab_proj_id] ~= nil then -- 1
      local is_unsaved_project = path == "" -- 2a
      local turned_undirty = prev_projects[tab_proj_id].is_dirty and not current_projects[tab_proj_id].is_dirty -- 2b
      if not (is_unsaved_project and turned_undirty) then goto skip end
    end

    -- process callbacks
    for _, func in ipairs(callbacks) do func(proj, path) end

    -- end of block, increment i for next loop
    ::skip::
    i = i + 1
  end

  -- update previous projects for next loop
  prev_projects = current_projects
  if exit then
    -- process exit callbacks
    for _, func in ipairs(exitCallbacks) do func() end
  else
    reaper.defer(loop)
  end
end

reaper.atexit(function()
  exit = true
end)

projectLoadCallback.startLoop = function()
  reaper.defer(loop)
end

projectLoadCallback.addCallback = function(func)
  table.insert(callbacks, func)
end

projectLoadCallback.addExitCallback = function(func)
  table.insert(exitCallbacks, func)
end

return projectLoadCallback