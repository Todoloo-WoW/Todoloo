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

---Base setup for new characters
Todoloo.TaskManager.EmptyCharacterSetup = {
    groups = {}
}

-- *****************************************************************************************************
-- ***** SETUP & INITIALIZATION
-- *****************************************************************************************************

---Setup Todoloo tasks for first time use
---@param characterFullName string Full character name in format "player-realm"
function Todoloo.TaskManager.FirstTimeSetup(characterFullName)
    TODOLOO_TASKS[characterFullName] = { groups = Todoloo.TaskManager.ExampleTasks }
end

---Reset Todoloo removing all tasks and groups.
---WARNING: This completely removes the characters current group and task setup. Use with caution.
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.Reset(characterFullName)
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    Todoloo.TaskManager.FirstTimeCharacterSetup(characterFullName)
end

---Do first time setup on character
---@param characterFullName string Character fule name in format "player-realm"
function Todoloo.TaskManager.FirstTimeCharacterSetup(characterFullName)
    TODOLOO_TASKS[characterFullName] = Todoloo.TaskManager.EmptyCharacterSetup
end

---Initialize task manager
function Todoloo.TaskManager.Initialize()
    local characterFullName = Todoloo.Utils.GetCharacterFullName()

    if TODOLOO_TASKS == nil then
        TODOLOO_TASKS = {}
        Todoloo.TaskManager.FirstTimeSetup(characterFullName)
    end

    local character = TODOLOO_TASKS[characterFullName]
    if character == nil then
        -- character doesn't exist - do first time character setup
        Todoloo.TaskManager.FirstTimeCharacterSetup(characterFullName)
    end
end

-- *****************************************************************************************************
-- ***** CHARACTERS
-- *****************************************************************************************************

---@class Character
---@field groups Group[] All groups for character

---Get all characters
---@return Character[]
function Todoloo.TaskManager.GetAllCharacters()
    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    return TODOLOO_TASKS
end

---Get character
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Character
function Todoloo.TaskManager.GetCharacter(characterFullName)
    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    return TODOLOO_TASKS[characterFullName]
end

-- *****************************************************************************************************
-- ***** GROUPS
-- *****************************************************************************************************

---@class Group
---@field name string Name of the group
---@field tasks Task[] Array of tasks nested under the group

---Get all groups
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Group[]
function Todoloo.TaskManager.GetAllGroups(characterFullName)
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    return TODOLOO_TASKS[characterFullName].groups
end

---Get specific group by index
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Group
function Todoloo.TaskManager.GetGroup(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    return TODOLOO_TASKS[characterFullName].groups[index]
end

---Get the total number of tasks for a given group
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return integer # Total number of tasks
function Todoloo.TaskManager.GetNumTasks(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local group = TODOLOO_TASKS[characterFullName].groups[index]
    return #group.tasks
end

---Are all tasks in this group complete?
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return boolean
function Todoloo.TaskManager.IsGroupComplete(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    local group = TODOLOO_TASKS[characterFullName].groups[index]
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
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Group # The newly created group
---@return integer # Group index within character tasks
function Todoloo.TaskManager.AddGroup(name, characterFullName)
    assert(name)

    name = name or "No name"

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    local character = TODOLOO_TASKS[characterFullName]

    local group = { name = name, tasks = {} }

    table.insert(character.groups, group)
    
    local groupIndex = #character.groups

    return group, groupIndex
end

---Update group
---@param index integer Index of the group within the task table
---@param newName string New name/title of the group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.UpdateGroup(index, newName, characterFullName)
    assert(index)
    assert(newName)

    newName = newName or "No name"

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    TODOLOO_TASKS[characterFullName].groups[index].name = newName
end

---Remove group
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.RemoveGroup(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    table.remove(TODOLOO_TASKS[characterFullName].groups, index)
end

---Reset group, removing all tasks
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.ResetGroup(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    TODOLOO_TASKS[characterFullName].groups[index].tasks = {}
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
---@param groupIndex integer Index of the group within the task table
---@param index integer Index of the task within the group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Task
function Todoloo.TaskManager.GetTask(groupIndex, index, characterFullName)
    assert(groupIndex)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    return TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index]
end

---Add new task to group
---@param groupIndex integer Index of the group in the task table
---@param name string Name/title of the task
---@param description string? Optional description of the task
---@param reset reset? Reset interval (sets default if none provided)
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Task # The newly created task
---@return integer # Index of the newly created task
function Todoloo.TaskManager.AddTask(groupIndex, name, description, reset, characterFullName)
    assert(groupIndex)
    assert(name)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    reset = reset or Todoloo.TaskManager.DefaultResetInterval

    local  task = {
        name = name,
        description = description,
        reset = reset,
        completed = false
    }
    
    table.insert(TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks, task)

    local index = #TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks

    return task, index
end

---Update task
---@param groupIndex integer Index of the group within the table
---@param index integer Index of the task within the group
---@param name string New name for the task
---@param description string? New description for the task
---@param reset reset New reset interval for the task
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.UpdateTask(groupIndex, index, name, description, reset, characterFullName)
    assert(groupIndex)
    assert(index)
    assert(name)
    assert(reset)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local completed = TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index].completed
    TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index] = {
        name = name,
        description = description,
        reset = reset,
        completed = completed
    }
end

---Remove task
---@param groupIndex integer Index of the group within the table
---@param index integer Index of the task within the group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.RemoveTask(groupIndex, index, characterFullName)
    assert(groupIndex)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    table.remove(TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks, index)
end

---Set task completion
---@param groupIndex integer Index of the group within the table
---@param index integer Index of the task within the group
---@param completed boolean Whether or not the task should be marked as completed
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.SetTaskCompletion(groupIndex, index, completed, characterFullName)
    assert(groupIndex)
    assert(index)
    
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index].completed = completed
end

---Reset completion state on task
---@param groupIndex integer Index of the group within the task table
---@param index integer Index of the task within the group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.ResetTask(groupIndex, index, characterFullName)
    assert(groupIndex)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index].completed = false
end

-- *****************************************************************************************************
-- ***** DATA PROVIDER
-- *****************************************************************************************************

---Generate data provider for use in scroll box
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function Todoloo.TaskManager.GenerateDataProvider(characterFullName)
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    local groups = TODOLOO_TASKS[characterFullName].groups

    local dataProvider = CreateTreeDataProvider()

    for groupIndex, group in pairs(groups) do
        local groupInfo = { id = groupIndex, name = group.name }
        local groupNode = dataProvider:Insert({ groupInfo = groupInfo })

        groupNode:Insert({ topPadding = true, order = -1 })

        for taskIndex, task in pairs(group.tasks) do
            local taskInfo = {
                groupId = groupIndex,
                id = taskIndex,
                name = task.name,
                description = task.description,
                reset = task.reset,
                completed = task.completed
            }

            groupNode:Insert({ taskInfo = taskInfo, order = 0 })
        end

        groupNode:Insert({ bottomPadding = true, order = 1 })
    end

    return dataProvider
end

-- *****************************************************************************************************
-- ***** TASK MANAGER INFO
-- *****************************************************************************************************

---@class OpenTask
---@field taskId integer Index of the task within its respective group
---@field groupId integer Index of the tasks respective group within Todoloo tasks

---@class TaskManagerInfo
---@field openTask OpenTask? Info on the task that should be opened in the task manager
---@field openGroupId integer ID of the group that should be opened in the task manager

---@return TaskManagerInfo # Current task manager info
function Todoloo.TaskManager.GetTaskManagerInfo()
    return { }
end