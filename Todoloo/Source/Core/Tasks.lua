local filters = {
    ShownCharacters = { },
    TaskNameFilter = ""
}

function Todoloo.Tasks.Initialize()
    Todoloo.EventBus:RegisterSource(Todoloo.Tasks, "todoloo_tasks")
    local currentCharacterFullName = Todoloo.Utils.GetCharacterFullName()
    table.insert(filters.ShownCharacters, currentCharacterFullName)
end

function Todoloo.Tasks.CheckAllFilters()
    Todoloo.Tasks.UncheckAllFilters()

    local characters = Todoloo.TaskManager:GetAllCharacters()
    for characterFullName, _ in pairs(characters) do
        if not Todoloo.Tasks.IsCharacterFiltered(characterFullName) then
            table.insert(filters.ShownCharacters, characterFullName)
        end
    end

    Todoloo.EventBus:TriggerEvent(Todoloo.Tasks, Todoloo.Tasks.Events.FILTER_CHANGED)
end

function Todoloo.Tasks.UncheckAllFilters()
    filters.ShownCharacters = {}

    Todoloo.EventBus:TriggerEvent(Todoloo.Tasks, Todoloo.Tasks.Events.FILTER_CHANGED)
end

function Todoloo.Tasks.SetCharacterFilter(characterFullName, setSelected)
    if setSelected then
        table.insert(filters.ShownCharacters, characterFullName)
    else
        local index = Todoloo.Utils.StringArrayIndexOf(filters.ShownCharacters, characterFullName)
        if index then
            table.remove(filters.ShownCharacters, index)
        end
    end

    Todoloo.EventBus:TriggerEvent(Todoloo.Tasks, Todoloo.Tasks.Events.FILTER_CHANGED)
end

function Todoloo.Tasks.IsCharacterFiltered(characterFullName)
    return Todoloo.Utils.StringArrayContains(filters.ShownCharacters, characterFullName)
end

function Todoloo.Tasks.IsUsingDefaultFilters()
    local currentCharacterFullName = Todoloo.Utils.GetCharacterFullName()

    return #filters.ShownCharacters == 1 and Todoloo.Tasks.IsCharacterFiltered(currentCharacterFullName)
end

function Todoloo.Tasks.SetDefaultFilters()
    local currentCharacterFullName = Todoloo.Utils.GetCharacterFullName()
    filters.ShownCharacters = {
        currentCharacterFullName
    }

    Todoloo.EventBus:TriggerEvent(Todoloo.Tasks, Todoloo.Tasks.Events.FILTER_CHANGED)
end

local function SortStrings(lhs, rhs)
    return strcmputf8i(lhs, rhs) < 0;
end

local function GetSortedCharactersTable(characters)
    local nameTable = {}
    for characterName, _ in pairs(characters) do
        table.insert(nameTable, characterName)
    end

    table.sort(nameTable, SortStrings)

    return nameTable
end

function Todoloo.Tasks.InitFilterMenu(dropdown)
    dropdown:SetDefaultCallback(function()
        Todoloo.Tasks.SetDefaultFilters()
    end)

    dropdown:SetIsDefaultCallback(function()
        return Todoloo.Tasks.IsUsingDefaultFilters()
    end)

    dropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_TODOLOO_TASKS_FILTER")

        rootDescription:CreateButton(TODOLOO_L_TASK_FILTER_CHECK_ALL, Todoloo.Tasks.CheckAllFilters)
        rootDescription:CreateButton(TODOLOO_L_TASK_FILTER_UNCHECK_ALL, Todoloo.Tasks.UncheckAllFilters)

        rootDescription:CreateDivider()

        -- Add all realms to filter system as title.
        local realms = Todoloo.TaskManager:GetAllRealms()
        table.sort(realms, SortStrings)
        for _, realm in pairs(realms) do
            rootDescription:CreateTitle(realm)

            -- get all realm characters and add to filter system as checkboxes
            local realmCharacters = Todoloo.TaskManager:GetAllCharacters(realm)
            local sortedCharacters = GetSortedCharactersTable(realmCharacters)

            for _, characterFullName in ipairs(sortedCharacters) do
                rootDescription:CreateCheckbox(characterFullName, function()
                    return Todoloo.Tasks.IsCharacterFiltered(characterFullName)
                end, function()
                    Todoloo.Tasks.SetCharacterFilter(characterFullName, not Todoloo.Tasks.IsCharacterFiltered(characterFullName))
                end)
            end
        end

    end)
end

local function BuildTaskListEntries(characters, searchCriteria)
    local result = {}
    local searchText = searchCriteria and string.lower(searchCriteria)

    for characterFullName, character in pairs(characters) do
        local characterEntry = {
            groups = {}
        }

        for groupId, group in ipairs(character.groups) do
            local groupEntry = {
                id = groupId,
                groupRef = group,
                tasks = {}
            }

            for taskId,  task in ipairs(group.tasks) do
                local matches = not searchText or string.find(string.lower(task.name), searchText, 1, true)

                if matches then
                    table.insert(groupEntry.tasks, {
                        id = taskId,
                        taskRef = task
                    })
                end
            end

            local groupMatches = not searchText or string.find(string.lower(group.name), searchText, 1, true)

            if groupMatches or #groupEntry.tasks > 0 then
                table.insert(characterEntry.groups, groupEntry)
            end
        end

        if not searchText or #characterEntry.groups > 0 then
            result[characterFullName] = characterEntry
        end
    end

    return result
end

local function SortCharacterData(lhs, rhs)
    if lhs ~= nil and rhs == nil then
        return true
    elseif rhs ~= nil and lhs == nil then
        return false
    end
    
    local lhsData = lhs:GetData()
    local rhsData = rhs:GetData()

    if lhsData.isCurrentCharacter then
        return true
    elseif rhsData.isCurrentCharacter then
        return false
    end

    local lhsCharacterName, lhsRealmName = strsplit("-", lhsData.character)
    local rhsCharacterName, rhsRealmName = strsplit("-", rhsData.character)

    if lhsRealmName ~= rhsRealmName then
        return strcmputf8i(lhsRealmName, rhsRealmName) < 0;
    end    
    
    return strcmputf8i(lhsCharacterName, rhsCharacterName) < 0;
end

function Todoloo.Tasks.GenerateTaskDataProvider(searching)
    local characters = {}
    for _, characterFullName in pairs(filters.ShownCharacters) do
        local character = Todoloo.TaskManager:GetCharacter(characterFullName)
        characters[characterFullName] = character
    end

    local searchCriteria
    if searching then
        searchCriteria = filters.TaskNameFilter
    end

    local characterEntries = BuildTaskListEntries(characters, searchCriteria)

    local currentCharacter = Todoloo.Utils.GetCharacterFullName()
    local dataProvider = CreateTreeDataProvider()
    local node = dataProvider:GetRootNode()

    local affectChildren = false
    local skipSort = false
    node:SetSortComparator(SortCharacterData, affectChildren, skipSort)

    for characterFullName, characterEntry in pairs(characterEntries) do
        local characterInfo = {
            name = characterFullName
        }

        local characterNode = node:Insert({
            characterInfo = characterInfo,
            character = characterFullName,
            isCurrentCharacter = characterFullName == currentCharacter
        })

        for _, groupEntry in ipairs(characterEntry.groups) do
            local group = groupEntry.groupRef

            local groupInfo = {
                character = characterFullName,
                id = groupEntry.id,
                name = group.name,
                reset = group.reset,
                groupRef = group
            }

            local groupNode = characterNode:Insert({
                groupInfo = groupInfo,
                character = characterFullName
            })
    
            groupNode:Insert({
                topPadding = true,
                order = -1
            })
    
            for _, taskEntry in ipairs(groupEntry.tasks) do
                local task = taskEntry.taskRef

                local taskInfo = {
                    groupId = groupEntry.id,
                    character = characterFullName,
                    id = taskEntry.id,
                    name = task.name,
                    description = task.description,
                    reset = task.reset,
                    target = task.target,
                    progress = task.progress,
                    completed = task.completed,
                    taskRef = task
                }
    
                groupNode:Insert({
                    taskInfo = taskInfo,
                    character = characterFullName,
                    order = 0
                })
            end
    
            groupNode:Insert({
                bottomPadding = true,
                order = 1
            })
        end
    end

    return dataProvider
end

function Todoloo.Tasks.OnTaskListSearchTextChanged(text)
    if strcmputf8i(filters.TaskNameFilter, text) == 0 then
        return
    end

    filters.TaskNameFilter = text

    Todoloo.EventBus:TriggerEvent(Todoloo.Tasks, Todoloo.Tasks.Events.TASK_LIST_UPDATE)
end

function Todoloo.Tasks.GetTaskListSearchText()
    return filters.TaskNameFilter
end

function Todoloo.Tasks.BuildTrackerGroupInfos()
    local infos = {}
    local showCompleted = Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS)

    for groupId, group in ipairs(Todoloo.TaskManager:GetAllGroups()) do
        local numTasks = #group.tasks
        local numCompletedTasks = 0

        for _, task in ipairs(group.tasks) do
            if task.completed then
                numCompletedTasks = numCompletedTasks + 1
            end
        end

        local isComplete = numCompletedTasks == numTasks

        if showCompleted or not isComplete then
            table.insert(infos, {
                id = groupId,
                name = group.name,
                groupRef = group,
                numTasks = numTasks,
                numCompletedTasks = numCompletedTasks,
                isComplete = isComplete
            })
        end
    end

    return infos
end

function Todoloo.Tasks.BuildTrackerTaskInfos(groupId)
    local infos = {}
    local orderByCompletion = Todoloo.Config.Get(Todoloo.Config.Options.ORDER_BY_COMPLETION)
    local completedInfos = orderByCompletion and {} or nil

    for taskId, task in ipairs(Todoloo.TaskManager:GetGroupTasks(groupId)) do
        local info = {
            id = taskId,
            taskRef = task,
            name = task.name,
            completed = task.completed,
            progress = task.progress,
            target = task.target
        }

        if completedInfos and task.completed then
            table.insert(completedInfos, info)
        else
            table.insert(infos, info)
        end
    end

    if completedInfos then
        for _, info in ipairs(completedInfos) do
            table.insert(infos, info)
        end
    end

    return infos
end

function Todoloo.Tasks.ResolveTrackerTask(groupId, taskId, taskRef)
    if not groupId or not taskId or not taskRef then
        return
    end

    local group = Todoloo.TaskManager:GetGroup(groupId)

    if group and group.tasks[taskId] == taskRef then
        return taskRef
    end
end