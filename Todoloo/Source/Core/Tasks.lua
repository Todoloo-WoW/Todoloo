local _, Todoloo = ...

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

function Todoloo.Tasks.InitFilterMenu(dropdown, level, onUpdate)
    local filterSystem = {}
    filterSystem.onUpdate = onUpdate
    filterSystem.filters =
    {
        {
            type = FilterComponent.TextButton,
            text = "Check all",
            set = function()
                Todoloo.Tasks.CheckAllFilters()
            end
        },
        {
            type = FilterComponent.TextButton,
            text = "Uncheck all",
            set = function()
                Todoloo.Tasks.UncheckAllFilters()
            end
        },
        { type = FilterComponent.Separator }
    }

    -- add all realms to filter system as title
    local realms = Todoloo.TaskManager:GetAllRealms()
    table.sort(realms, SortStrings)
    for _, realm in pairs(realms) do
        local realmFilter =
        {
            type = FilterComponent.Title,
            text = realm
        }
        table.insert(filterSystem.filters, realmFilter)

        -- get all realm characters and add to filter system as checkboxes
        local realmCharacters = Todoloo.TaskManager:GetAllCharacters(realm)
        local sortedCharacters = GetSortedCharactersTable(realmCharacters)
        
        for _, characterFullName in ipairs(sortedCharacters) do
            local characterName = select(1, strsplit("-", characterFullName))
            local characterFilter =
            {
                type = FilterComponent.Checkbox,
                text = characterName,
                set = function(value)
                    Todoloo.Tasks.SetCharacterFilter(characterFullName, value)
                end,
                isSet = function()
                    return Todoloo.Tasks.IsCharacterFiltered(characterFullName)
                end
            }
            table.insert(filterSystem.filters, characterFilter)
        end
    end

    FilterDropDownSystem.Initialize(dropdown, filterSystem, level)

    return filterSystem
end

local function GetFilteredTasks(characters, searchCriteria)
    local result = {}
    
    for characterFullName, character in pairs(characters) do
        local characterMatch = false
        local characterEntry = {
            groups = {}
        }

        for _, group in pairs(character.groups) do
            local match = false
            local groupEntry = {
                name = group.name,
                tasks = {}
            }

            for _, task in pairs(group.tasks) do
                if string.find(string.lower(task.name), string.lower(searchCriteria)) then
                    table.insert(groupEntry.tasks, task)
                    match = true
                    characterMatch = true
                end
            end

            if not match then
                if string.find(string.lower(group.name), string.lower(searchCriteria)) then
                    match = true
                    characterMatch = true
                end
            end

            if match then
                table.insert(characterEntry.groups, groupEntry)
            end
        end

        -- only add the character if we've found matches on either tasks or groups
        if characterMatch then
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

    if searching then
        characters = GetFilteredTasks(characters, filters.TaskNameFilter)
    end

    local currentCharacter = Todoloo.Utils.GetCharacterFullName()
    local dataProvider = CreateTreeDataProvider()
    local node = dataProvider:GetRootNode()

    local affectChildren = false
    local skipSort = false
    node:SetSortComparator(SortCharacterData, affectChildren, skipSort)

    for characterFullName, character in pairs(characters) do
        local characterInfo = { name = characterFullName }
        local isCurrentCharacter = characterFullName == currentCharacter
        local characterNode = node:Insert({ characterInfo = characterInfo, character = characterFullName, isCurrentCharacter = isCurrentCharacter })

        for groupIndex, group in pairs(character.groups) do
            local groupInfo = {
                character = characterFullName,
                id = groupIndex,
                name = group.name,
                reset = group.reset
            }
            local groupNode = characterNode:Insert({ groupInfo = groupInfo, character = characterFullName })
    
            groupNode:Insert({ topPadding = true, order = -1 })
    
            for taskIndex, task in pairs(group.tasks) do
                local taskInfo = {
                    groupId = groupIndex,
                    character = characterFullName,
                    id = taskIndex,
                    name = task.name,
                    description = task.description,
                    reset = task.reset,
                    completed = task.completed
                }
    
                groupNode:Insert({ taskInfo = taskInfo, character = characterFullName, order = 0 })
            end
    
            groupNode:Insert({ bottomPadding = true, order = 1 })
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