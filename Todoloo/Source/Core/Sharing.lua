--[[
Sharing format v1: TODOLOO:1:<hex-encoded payload>
Each field uses <byte length>:<value>, preserving UTF-8 and line breaks.

Field order:
- Export: scope, group count
- Group: name, reset, task count
- Task: name, description, effective reset, target, item count, item IDs

Reset: 0 = no group reset, 1 = manual, 2 = daily, 3 = weekly.
Import validates everything before appending groups; progress starts at zero.
]]

Todoloo.Sharing = {}

local Sharing = Todoloo.Sharing
local PREFIX = "TODOLOO:1:"
local MAX_SIZE = 200000

local function Integer(value, minimum, maximum)
    assert(
        type(value) == "number"
            and value % 1 == 0
            and value >= minimum
            and value <= maximum
    )

    return value
end

function Sharing.Export(character, groupId, taskId)
    local success, result = pcall(function()
        local groups = Todoloo.TaskManager:GetAllGroups(character)
        local kind = taskId and "task"
            or groupId and "group"
            or "character"

        if groupId then
            local group = assert(groups[groupId])

            if taskId then
                groups = {
                    {
                        name = group.name,
                        reset = group.reset,
                        tasks = { assert(group.tasks[taskId]) }
                    }
                }
            else
                groups = { group }
            end
        end

        local parts = {}

        local function Put(value)
            value = tostring(value)
            parts[#parts + 1] = #value .. ":" .. value
        end

        Put(kind)
        Put(#groups)

        for _, group in ipairs(groups) do
            Put(group.name)
            Put(group.reset or 0)
            Put(#group.tasks)

            for _, task in ipairs(group.tasks) do
                Put(task.name)
                Put(task.description or "")
                Put(
                    group.reset
                        or task.reset
                        or TODOLOO_DEFAULT_RESET_INTERVAL
                )
                Put(task.target or 1)

                local items = task.lootItemIDs or {}
                Put(#items)

                for _, itemID in ipairs(items) do
                    Put(itemID)
                end
            end
        end

        local payload = table.concat(parts)
        local encoded = PREFIX .. payload:gsub(".", function(byte)
            return string.format("%02x", string.byte(byte))
        end)

        assert(#encoded <= MAX_SIZE)
        assert(Sharing.Decode(encoded))

        return encoded
    end)

    if success then
        return result
    end

    return nil, TODOLOO_L_SHARE_EXPORT_ERROR
end

function Sharing.Decode(text)
    local success, result = pcall(function()
        assert(type(text) == "string" and #text <= MAX_SIZE)

        text = text:gsub("%s", "")
        assert(text:sub(1, #PREFIX) == PREFIX)

        local hex = text:sub(#PREFIX + 1)
        assert(#hex % 2 == 0 and not hex:find("[^%x]"))

        local payload = hex:gsub("%x%x", function(byte)
            return string.char(tonumber(byte, 16))
        end)

        local position = 1

        local function Read()
            local separator = payload:find(":", position, true)
            assert(separator)

            local lengthText = payload:sub(position, separator - 1)
            assert(
                #lengthText <= 6
                    and lengthText:match("^%d+$")
            )

            local length = tonumber(lengthText)
            assert(separator + length <= #payload)

            local value = payload:sub(
                separator + 1,
                separator + length
            )

            position = separator + length + 1
            return value
        end

        local function Number(minimum, maximum)
            local value = Read()
            assert(value:match("^%d+$"))

            return Integer(tonumber(value), minimum, maximum)
        end

        local function Name()
            local value = Read()
            assert(#value <= 1024 and value:find("%S"))
            return value
        end

        local data = {
            kind = Read(),
            groups = {},
            taskCount = 0
        }

        assert(
            data.kind == "character"
                or data.kind == "group"
                or data.kind == "task"
        )

        local groupCount = Number(0, 1000)

        if data.kind ~= "character" then
            assert(groupCount == 1)
        end

        for groupIndex = 1, groupCount do
            local group = {
                name = Name(),
                tasks = {}
            }

            local reset = Number(0, 3)

            if reset ~= 0 then
                group.reset = reset
            end

            local taskCount = Number(0, 5000)
            data.taskCount = data.taskCount + taskCount
            assert(data.taskCount <= 5000)

            if data.kind == "task" then
                assert(taskCount == 1)
            end

            for taskIndex = 1, taskCount do
                local task = {
                    name = Name(),
                    description = Read(),
                    progress = 0,
                    completed = false
                }

                assert(#task.description <= 16384)

                if task.description == "" then
                    task.description = nil
                end

                local taskReset = Number(1, 3)

                if not group.reset then
                    task.reset = taskReset
                end

                task.target = Number(1, 2147483647)
                task.lootItemIDs = {}

                local itemCount = Number(0, 1000)
                local seen = {}

                for itemIndex = 1, itemCount do
                    local itemID = Number(1, 2147483647)

                    if not seen[itemID] then
                        table.insert(task.lootItemIDs, itemID)
                        seen[itemID] = true
                    end
                end

                group.tasks[taskIndex] = task
            end

            data.groups[groupIndex] = group
        end

        assert(position == #payload + 1)
        return data
    end)

    if success then
        return result
    end

    return nil, TODOLOO_L_SHARE_IMPORT_ERROR
end

function Sharing.Import(text, character)
    local data, message = Sharing.Decode(text)

    if not data then
        return nil, message
    end

    character = character or Todoloo.Utils.GetCharacterFullName()

    local destination = Todoloo.TaskManager:GetCharacter(character)

    if not destination then
        return nil, TODOLOO_L_SHARE_IMPORT_ERROR
    end

    -- Validation completes before saved data changes.
    if #data.groups == 0 then
        return true
    end

    for _, group in ipairs(data.groups) do
        table.insert(destination.groups, group)
    end

    -- Existing listeners refresh the manager and both trackers.
    Todoloo.EventBus:TriggerEvent(
        Todoloo.TaskManager,
        Todoloo.Tasks.Events.GROUP_ADDED,
        #destination.groups,
        character
    )

    return true
end