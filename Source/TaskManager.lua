---@enum reset Reset intervals defining when a task should automatically remove completion mark
Todoloo.TaskManager.ResetIntervals = {
    -- Manual reset will never automatically reset the completion mark
    Manually    = 1,
    -- Day reset will automatically reset the completion mark every day
    Daily       = 2,
    -- Week reset will automatically reset the completion mark each reset day
    Weekly      = 3
}

-- Default reset interval on new tasks
Todoloo.TaskManager.DefaultResetInterval = Todoloo.TaskManager.ResetIntervals.Manually

---Default example tasks for first time initialization.
---These are some what irrelevant, but will show the player some hints for usage.
Todoloo.TaskManager.ExampleTasks = {
    {
        name = "Mounts",
        tasks = {
            {
                name = "Invincible's Reins",
                description = "Icecornw - Lich King",
                reset = 3,
                completed = false
            },
            {
                name = "Cartel Master's Gearglider",
                description = nil,
                reset = 1,
                completed = false
            },
            {
                name = "Swift White Hawkstrider",
                description = nil,
                reset = 2,
                completed = false
            },
            {
                name = "Reins of the Raven Lord",
                description = nil,
                reset = 2,
                completed = false
            },
            {
                name = "Swift Zulian Panther",
                description = nil,
                reset = 2,
                completed = false
            }
        }
    },
    {
        name = "Transmog runs",
        tasks = {
            {
                name = "Antorus, the Burning Throne",
                description = nil,
                reset = 3,
                completed = false
            },
            {
                name = "Dragon Soul",
                description = nil,
                reset = 3,
                completed = false
            },
            {
                name = "Firelands",
                description = nil,
                reset = 3,
                completed = false
            },
            {
                name = "Ny'alotha, the Waking City",
                description = nil,
                reset = 3,
                completed = false
            }
        }
    },
    {
        name = "Profession stuff",
        tasks = {
            {
                name = "Blacksmithing weeklies",
                description = nil,
                reset = 3,
                completed = false
            },
            {
                name = "Mining weeklies",
                description = nil,
                reset = 3,
                completed = false
            },
            {
                name = "Check barting boulder quests",
                description = nil,
                reset = 3,
                completed = false
            }   
        }
    }
}

-- *****************************************************************************************************
-- ***** SETUP & INITIALIZATION
-- *****************************************************************************************************

---Setup Todoloo tasks for first time use
function Todoloo.TaskManager.FirstTimeSetup()
    Todoloo.Debug.Message("Setting up first time use")
    TODOLOO_TASKS = Todoloo.TaskManager.ExampleTasks
end

---Reset Todoloo removing all tasks and groups
---
---WARNING: This completely removes the users current group and task setup. Use with caution.
function Todoloo.TaskManager.Reset()
    TODOLOO_TASKS = {}
end

---Initialize task manager
function Todoloo.TaskManager.Initialize()
    Todoloo.Debug.Message("Initializing task manager")

    if TODOLOO_TASKS == nil then
        if not Todoloo.Config.Get(Todoloo.Config.Options.FIRST_TIME_STARTUP_INITIALIZED) then
            -- setup first time use if this is indeed the first time the addon is loaded on the account
            Todoloo.TaskManager.FirstTimeSetup()
            Todoloo.Config.Set(Todoloo.Config.Options.FIRST_TIME_STARTUP_INITIALIZED, true)
        else
            Todoloo.TaskManager.Reset()
        end
    end
end

-- *****************************************************************************************************
-- ***** GROUPS
-- *****************************************************************************************************

---@class Group
---@field name string Name of the group
---@field tasks Task[] Array of tasks nested under the group

---Get all groups
---@return Group[]
function Todoloo.TaskManager.GetAll()
    Todoloo.Debug.Message("Todoloo.TaskManager.GetAll")
    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    return TODOLOO_TASKS
end

---Get specific group by index
---@param index integer The index of the group within the table
---@return Group
function Todoloo.TaskManager.GetGroup(index)
    if index == nil then
        error("Cannot retrieve group at index 'nil'")
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    return TODOLOO_TASKS[index]
end

---Get the total number of tasks for a given group
---@param index integer Index of the group
---@return integer number Total number of tasks
function Todoloo.TaskManager.GetNumTasks(index)
    assert(index)

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    local group = TODOLOO_TASKS[index]
    return #group.tasks
end

---Are all tasks in this group complete?
---@param index integer The index of the group within the table
function Todoloo.TaskManager.IsGroupComplete(index)
    assert(index)

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    local group = TODOLOO_TASKS[index]
    local isComplete = true
    for _, task in pairs(group.tasks) do
        if not task.completed then
            return false
        end
    end

    return isComplete
end

---Add new group
---@param name string Name/title of the group
function Todoloo.TaskManager.AddGroup(name)
    if name == nil then
        error("Group name cannot be nil")
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    else
        table.insert(TODOLOO_TASKS, { name = name, tasks = {} })
    end
end

---Update group
---@param index integer The index of the group within the table
---@param new_name string New name/title of the group
function Todoloo.TaskManager.UpdateGroup(index, new_name)
    assert(index)
    assert(new_name)

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    else
        TODOLOO_TASKS[index].name = new_name
    end
end

---Remove group
---@param index integer The index of the group within the table
function Todoloo.TaskManager.RemoveGroup(index)
    if index == nil then
        error("Cannot remove group at index 'nil'")
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    else
        table.remove(TODOLOO_TASKS, index)
    end
end

---Reset group, removing all tasks
---@param index integer The index of the group within the table
function Todoloo.TaskManager.ResetGroup(index)
    if index == nil then
        error("Cannot remove group at index 'nil'")
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    else
        TODOLOO_TASKS[index].tasks = {}
    end
end

-- *****************************************************************************************************
-- ***** TASKS
-- *****************************************************************************************************

---@class Task
---@field name string Name of the task
---@field description string|nil Optional description of the task
---@field reset reset Reset interval for automatic reapperances in the task manager
---@field completed boolean Whether or not this task has been completed

---Get specific task in group by index
---@param groupIndex integer The index of the group within the table
---@param index integer The index of the task within the group task table
---@return Task
function Todoloo.TaskManager.GetTask(groupIndex, index)
    if groupIndex == nil then
        error("Cannot retrieve group at index 'nil'")
    elseif index == nil then
        error("Cannot retrieve task at index 'nil'")
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    return TODOLOO_TASKS[groupIndex].tasks[index]
end

---Add new task to group
---@param groupIndex integer The index of the group in the table
---@param name string Name/title of the task
---@param description string? Optional description of the task
---@param reset reset Reset interval
function Todoloo.TaskManager.AddTask(groupIndex, name, description, reset)
    if groupIndex == nil then
        error("Group index cannot be nil")
    elseif name == nil then
        error("Task name cannot be nil")
    end

    reset = reset or Todoloo.TaskManager.DefaultResetInterval

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    else
        table.insert(TODOLOO_TASKS[groupIndex].tasks, {
            name = name,
            description = description,
            reset = reset,
            completed = false
        })
    end
end

---Update task
---@param groupIndex integer The index of the group within the table
---@param index integer The index of the task within the group task table
---@param name string New name for the task
---@param description string? New description for the task
---@param reset reset New reset interval for the task
function Todoloo.TaskManager.UpdateTask(groupIndex, index, name, description, reset)
    if groupIndex == nil then
        error("Group index cannot be nil")
    elseif index == nil then
        error("Index cannot be nil")
    elseif name == nil then
        error("Task name cannot be nil")
    elseif reset == nil then
        error("Task reset interval cannot be nil")
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    else
        local completed = TODOLOO_TASKS[groupIndex].tasks[index].completed
        TODOLOO_TASKS[groupIndex].tasks[index] = {
            name = name,
            description = description,
            reset = reset,
            completed = completed
        }
    end
end

---Remove task
---@param groupIndex integer The index of the group within the table
---@param index integer The index of the task within the group task table
function Todoloo.TaskManager.RemoveTask(groupIndex, index)
    if groupIndex == nil then
        error("Cannot remove task at group index 'nil'")
    elseif index == nil then
        error("Cannot remove task at index 'nil'")
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    else
        table.remove(TODOLOO_TASKS[groupIndex].tasks, index)
    end
end

---Set task completion
---@param groupIndex integer The index of the group within the table
---@param index integer The index of the task within the group task table
---@param completed boolean Whether or not the task should be marked as completed
function Todoloo.TaskManager.SetTaskCompletion(groupIndex, index, completed)
    if groupIndex == nil then
        error("Cannot retrieve group at index 'nil'")
    elseif index == nil then
        error("Cannot retrieve task at index 'nil'")
    elseif completed == nil then
        error("Completed cannot be nil")  
    end

    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    TODOLOO_TASKS[groupIndex].tasks[index].completed = completed
end