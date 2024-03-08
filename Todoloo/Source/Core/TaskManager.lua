---@enum reset Reset intervals defining when a task should automatically remove completion mark
TODOLOO_RESET_INTERVALS = {
    -- Manual reset will never automatically reset the completion mark
    Manually    = 1,
    -- Day reset will automatically reset the completion mark every day
    Daily       = 2,
    -- Week reset will automatically reset the completion mark each reset day
    Weekly      = 3
}

-- Default reset interval on new tasks
TODOLOO_DEFAULT_RESET_INTERVAL = TODOLOO_RESET_INTERVALS.Manually

---Default example tasks for first time initialization.
---These are some what irrelevant, but will show the player some hints for usage.
TODLOO_FIRST_TIME_SETUP_TASKS = {
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
TODOLOO_EMPTY_CHARACTER_SETUP = {
    groups = {}
}

-- *****************************************************************************************************
-- ***** SETUP & INITIALIZATION
-- *****************************************************************************************************

TodolooTaskManagerMixin = {}

---Setup Todoloo tasks for first time use
---@param characterFullName string Full character name in format "player-realm"
function TodolooTaskManagerMixin:FirstTimeSetup(characterFullName)
    TODOLOO_TASKS[characterFullName] = { groups = TODLOO_FIRST_TIME_SETUP_TASKS }
end

---Reset Todoloo removing all tasks and groups.
---WARNING: This completely removes the characters current group and task setup. Use with caution.
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:Reset(characterFullName)
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    self:FirstTimeCharacterSetup(characterFullName)
end

---Do first time setup on character
---@param characterFullName string Character fule name in format "player-realm"
function TodolooTaskManagerMixin:FirstTimeCharacterSetup(characterFullName)
    TODOLOO_TASKS[characterFullName] = TODOLOO_EMPTY_CHARACTER_SETUP
end

function TodolooTaskManagerMixin:Init()
    Todoloo.EventBus:RegisterSource(self, "task_manager")

    self.taskNameFilter = ""
    self.taskManagerInfo = {}

    local characterFullName = Todoloo.Utils.GetCharacterFullName()

    if TODOLOO_TASKS == nil then
        TODOLOO_TASKS = {}
        self:FirstTimeSetup(characterFullName)
    end

    local character = TODOLOO_TASKS[characterFullName]
    if character == nil then
        -- character doesn't exist - do first time character setup
        self:FirstTimeCharacterSetup(characterFullName)
    end
end

-- *****************************************************************************************************
-- ***** CHARACTERS
-- *****************************************************************************************************

---@class Character
---@field groups Group[] All groups for character

---Get all characters
---@return Character[]
function TodolooTaskManagerMixin:GetAllCharacters()
    if TODOLOO_TASKS == nil then
        error("TODOLOO_TASKS not initialized")
    end

    return TODOLOO_TASKS
end

---Get character
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Character
function TodolooTaskManagerMixin:GetCharacter(characterFullName)
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
---@field reset reset? Reset interval for the group

---Get all groups
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Group[]
function TodolooTaskManagerMixin:GetAllGroups(characterFullName)
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    return TODOLOO_TASKS[characterFullName].groups
end

---Get specific group by index
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Group
function TodolooTaskManagerMixin:GetGroup(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    return TODOLOO_TASKS[characterFullName].groups[index]
end

---Get the total number of tasks for a given group
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return integer # Total number of tasks
function TodolooTaskManagerMixin:GetNumTasks(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local group = TODOLOO_TASKS[characterFullName].groups[index]
    return #group.tasks
end

---Get the total number of completed tasks for a given group
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return integer # Total number of completed tasks
function TodolooTaskManagerMixin:GetNumCompletedTasks(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local group = TODOLOO_TASKS[characterFullName].groups[index]

    local numCompletedTasks = 0
    for _, task in ipairs(group.tasks) do
        if task.completed then
            numCompletedTasks = numCompletedTasks + 1
        end
    end

    return numCompletedTasks
end

---Are all tasks in this group complete?
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return boolean
function TodolooTaskManagerMixin:IsGroupComplete(index, characterFullName)
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
function TodolooTaskManagerMixin:AddGroup(name, characterFullName)
    assert(name)

    name = name or "No name"

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    local character = TODOLOO_TASKS[characterFullName]

    local group = { name = name, tasks = {}, reset = nil }

    table.insert(character.groups, group)

    local groupIndex = #character.groups
    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.GROUP_ADDED, groupIndex)

    return group, groupIndex
end

---Update group
---@param index integer Index of the group within the task table
---@param newName string New name/title of the group
---@param resetInterval reset? New reset interval for the group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:UpdateGroup(index, newName, resetInterval, characterFullName)
    assert(index)
    assert(newName)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local group = TODOLOO_TASKS[characterFullName].groups[index]

    newName = newName or "No name"
    if resetInterval == nil and group.reset ~= nil then
        -- if the group reset is being removed, set the reset interval on the nested tasks
        for _, task in ipairs(group.tasks) do
            task.reset = group.reset
        end
    else
        -- if group reset is being set, remove reset interval from tasks
        for _, task in ipairs(group.tasks) do
            task.reset = nil
        end
    end

    group.name = newName
    group.reset = resetInterval

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.GROUP_UPDATED, index)
end

---Remove group
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:RemoveGroup(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    table.remove(TODOLOO_TASKS[characterFullName].groups, index)
    
    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.GROUP_REMOVED, index)
end

---Reset completion state on group tasks
---TODO: Test functionality
---@param index integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:ResetGroup(index, characterFullName)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    local tasks = TODOLOO_TASKS[characterFullName].groups[index].tasks

    for _, task in ipairs(tasks) do
        task.completed = false
    end

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.GROUP_RESET, index)
end

---Move group to new location
---@param groupId integer ID of the group 
---@param newGroupId integer ID of the new group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:MoveGroup(groupId, newGroupId, characterFullName)
    assert(groupId, "Group ID is required to move a group.")
    assert(newGroupId, "New group ID is required to move a group.")

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local group = TODOLOO_TASKS[characterFullName].groups[groupId]
    if not group then
        error("Group not found")
    end

    if newGroupId > #TODOLOO_TASKS[characterFullName].groups then
        --[[we need to handle the situationwhere the new task ID is greater than the length of the table.
            In those scenarios, we simply want to move the group to the last spot in the groups table, by settings
            the new group ID to the length of the groups table.]]--
        newGroupId = #TODOLOO_TASKS[characterFullName].groups
    end
    
    -- remove task at old location
    table.remove(TODOLOO_TASKS[characterFullName].groups, groupId)
    
    -- insert at new location
    table.insert(TODOLOO_TASKS[characterFullName].groups, newGroupId, group)

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.GROUP_MOVED, groupId, newGroupId)
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
function TodolooTaskManagerMixin:GetTask(groupIndex, index, characterFullName)
    assert(groupIndex)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    return TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index]
end

---Get tasks for a specific group
---@param groupIndex integer Index of the group within the task table
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Task[] # All tasks within the given group
function TodolooTaskManagerMixin:GetGroupTasks(groupIndex, characterFullName)
    assert(groupIndex)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    return TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks
end

---Add new task to group
---@param groupIndex integer Index of the group in the task table
---@param name string Name/title of the task
---@param description string? Optional description of the task
---@param reset reset? Reset interval (if the task group has a reset interval defined, this value is ignored. If not, and the value is not provided, the default reset interval will be set)
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
---@return Task # The newly created task
---@return integer # Index of the newly created task
function TodolooTaskManagerMixin:AddTask(groupIndex, name, description, reset, characterFullName)
    assert(groupIndex)
    assert(name)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    local group = TODOLOO_TASKS[characterFullName].groups[groupIndex]

    if group.reset ~= nil then
        -- if there's a reset interval defined on the group
        reset = nil
    else
        -- set to given reset interval or default
        reset = reset or TODOLOO_DEFAULT_RESET_INTERVAL
    end

    local  task = {
        name = name,
        description = description,
        reset = reset,
        completed = false
    }
    
    table.insert(TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks, task)

    local index = #TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks
    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.TASK_ADDED, groupIndex, index)

    return task, index
end

---Update task
---@param groupIndex integer Index of the group within the table
---@param index integer Index of the task within the group
---@param name string New name for the task
---@param description string? New description for the task
---@param reset reset? New reset interval for the task (if the task group has a reset interval defined, this value is ignored)
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:UpdateTask(groupIndex, index, name, description, reset, characterFullName)
    assert(groupIndex)
    assert(index)
    assert(name)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local group = TODOLOO_TASKS[characterFullName].groups[groupIndex]
    if group.reset ~= nil then
        -- if there's a reset interval defined on the group
        reset = nil
    else
        -- if there's no reset interval set on the group, a reset interval for the task is required
        assert(reset)
    end

    local completed = TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index].completed
    TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index] = {
        name = name,
        description = description,
        reset = reset,
        completed = completed
    }
    
    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.TASK_UPDATED, groupIndex, index)
end

---Remove task
---@param groupIndex integer Index of the group within the table
---@param index integer Index of the task within the group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:RemoveTask(groupIndex, index, characterFullName)
    assert(groupIndex)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    table.remove(TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks, index)

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.TASK_REMOVED, groupIndex, index)
end

---Set task completion
---@param groupIndex integer Index of the group within the table
---@param index integer Index of the task within the group
---@param completed boolean Whether or not the task should be marked as completed
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:SetTaskCompletion(groupIndex, index, completed, characterFullName)
    assert(groupIndex)
    assert(index)
    
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index].completed = completed

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.TASK_COMPLETION_SET, groupIndex, index)
end

---Reset completion state on task
---@param groupIndex integer Index of the group within the task table
---@param index integer Index of the task within the group
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:ResetTask(groupIndex, index, characterFullName)
    assert(groupIndex)
    assert(index)

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    TODOLOO_TASKS[characterFullName].groups[groupIndex].tasks[index].completed = false

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.TASK_RESET, groupIndex, index)
end

---Move task to new location
---@param taskId integer ID of the task to move
---@param groupId integer ID of the group the task is nested under
---@param newGroupId integer ID of the new group
---@param newTaskId integer? ID of the new task (defaults to bottom of the new group)
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:MoveTask(taskId, groupId, newGroupId, newTaskId, characterFullName)
    assert(taskId, "Task ID is required to move a task.")
    assert(groupId, "Group ID is required to move a task.")
    assert(newGroupId, "New group ID is required to move a task.")

    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()

    local task = TODOLOO_TASKS[characterFullName].groups[groupId].tasks[taskId]
    if not task then
        error("Task not found")
    end

    if groupId == newGroupId then
        --[[if we're moving the task within the same group, we need to handle the situation
            where the new task ID is greater than the length of the task table. In those scenarios,
            we simply want to move the task to the last spot in the task table, by settings
            the new task ID to the length of the table.]]--
        if newTaskId > #TODOLOO_TASKS[characterFullName].groups[newGroupId].tasks then
            newTaskId = #TODOLOO_TASKS[characterFullName].groups[newGroupId].tasks
        end
    else
        --[[if we're moving the task between groups, we need to set reset interval on the task,
            in the scenario where the old group had a reset interval, but the new one does not.
            We're basically setting the old group's reset interval specifically on the task.]]--
        local oldGroup = TODOLOO_TASKS[characterFullName].groups[groupId]
        local newGroup = TODOLOO_TASKS[characterFullName].groups[newGroupId]
        if newGroup.reset ~= nil then
            -- if a reset interval is defined on the new group, remove the tasks own reset interval
            task.reset = nil
        elseif oldGroup.reset ~= nil and newGroup.reset == nil then
            -- if the new group has no reset interval defined, set reset on the task to be equal to the old group's reset interval
            task.reset = oldGroup.reset
        end
    end
    
    -- remove task at old location
    table.remove(TODOLOO_TASKS[characterFullName].groups[groupId].tasks, taskId)

    if newTaskId then
        -- move task relative to another task
        table.insert(TODOLOO_TASKS[characterFullName].groups[newGroupId].tasks, newTaskId, task)
    else
        -- not moving relative to task, just add to the new group
        table.insert(TODOLOO_TASKS[characterFullName].groups[newGroupId].tasks, task)
    end

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.TASK_MOVED, taskId, groupId, newGroupId, newTaskId)
end

-- *****************************************************************************************************
-- ***** DATA PROVIDER
-- *****************************************************************************************************

local function GetFilteredTasks(groups, searchCriteria)
    local result = {}
    
    for _, group in pairs(groups) do
        local match = false
        local resultEntry = {
            name = group.name,
            tasks = {}
        }

        for _, task in pairs(group.tasks) do
            if string.find(string.lower(task.name), string.lower(searchCriteria)) then
                table.insert(resultEntry.tasks, task)
                match = true
            end
        end

        if not match then
            if string.find(string.lower(group.name), string.lower(searchCriteria)) then
                match = true
            end
        end

        if match then
            table.insert(result, resultEntry)
        end
    end

    return result
end

---Generate data provider for use in scroll box
---TODO: Does this belong in the task manager?
---@param searching boolean Are we currently searching?
---@param characterFullName string? Full character name in format "player-realm" (defaults to the currently logged in character)
function TodolooTaskManagerMixin:GenerateDataProvider(searching, characterFullName)
    characterFullName = characterFullName or Todoloo.Utils.GetCharacterFullName()
    local groups = TODOLOO_TASKS[characterFullName].groups

    if searching then
        groups = GetFilteredTasks(groups, self.taskNameFilter)
    end

    local dataProvider = CreateTreeDataProvider()

    for groupIndex, group in pairs(groups) do
        local groupInfo = { id = groupIndex, name = group.name, reset = group.reset }
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

function TodolooTaskManagerMixin:GetTaskNameFilter()
    return self.taskNameFilter
end

function TodolooTaskManagerMixin:OnTaskListSearchTextChanged(text)
    if strcmputf8i(self.taskNameFilter, text) == 0 then
        return
    end

    self.taskNameFilter = text

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Tasks.Events.TASK_LIST_UPDATE)
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

---TODO: Does this belong in the task manager, and is this even necessary?
---@return TaskManagerInfo # Current task manager info
function TodolooTaskManagerMixin:GetTaskManagerInfo()
    return {}
end