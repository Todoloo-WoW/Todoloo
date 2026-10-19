Todoloo.LootTracking = {}

local LootTracking = Todoloo.LootTracking
local lootPatterns = {}

local function EscapePattern(text)
    return (text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function AddLootPattern(formatString)
    if not formatString then
        return
    end

    local parts = {}
    local captureTypes = {}
    local position = 1

    while position <= #formatString do
        -- Matches ordinary and positional placeholders:
        -- %s, %d, %1$s, %2$d.
        local first, last = formatString:find("%%[%d%$]*[sd]", position)

        if not first then
            table.insert(parts, EscapePattern(formatString:sub(position)))
            break
        end

        table.insert(parts, EscapePattern(formatString:sub(position, first - 1)))

        local captureType = formatString:sub(last, last)
        table.insert(captureTypes, captureType)

        if captureType == "d" then
            table.insert(parts, "(%d+)")
        else
            table.insert(parts, "(.-)")
        end

        position = last + 1
    end

    table.insert(lootPatterns, {
        pattern = "^" .. table.concat(parts) .. "$",
        captureTypes = captureTypes
    })
end

function LootTracking.Initialize()
    if LootTracking.initialized then
        return
    end

    LootTracking.initialized = true

    AddLootPattern(LOOT_ITEM_SELF_MULTIPLE)
    AddLootPattern(LOOT_ITEM_SELF)
    AddLootPattern(LOOT_ITEM_PUSHED_SELF_MULTIPLE)
    AddLootPattern(LOOT_ITEM_PUSHED_SELF)

    EventRegistry:RegisterFrameEventAndCallback(
        "CHAT_MSG_LOOT",
        LootTracking.OnLootMessage,
        LootTracking
    )
end

function LootTracking.ParseMessage(message)
    if issecretvalue and issecretvalue(message) then
        return
    end

    if type(message) ~= "string" then
        return
    end

    for _, entry in ipairs(lootPatterns) do
        local captures = { message:match(entry.pattern) }

        if #captures > 0 then
            local itemID
            local quantity = 1

            for index, captureType in ipairs(entry.captureTypes) do
                local value = captures[index]

                if captureType == "s" then
                    itemID = tonumber(value:match("|Hitem:(%d+):"))
                elseif captureType == "d" then
                    quantity = tonumber(value)
                end
            end

            if itemID and quantity and quantity > 0 then
                return itemID, quantity
            end
        end
    end
end

function LootTracking:OnLootMessage(message)
    local itemID, quantity = LootTracking.ParseMessage(message)

    if itemID then
        self:RecordLoot(itemID, quantity)
    end
end

function LootTracking:RecordLoot(itemID, quantity)
    if not Todoloo.TaskManager then
        return
    end

    local characterFullName = Todoloo.Utils.GetCharacterFullName()
    local groups = Todoloo.TaskManager:GetAllGroups(characterFullName)

    for groupIndex, group in ipairs(groups) do
        for taskIndex, task in ipairs(group.tasks) do
            if not task.completed then
                for _, attachedItemID in ipairs(task.lootItemIDs or {}) do
                    if attachedItemID == itemID then
                        Todoloo.TaskManager:AdjustTaskProgress(
                            groupIndex,
                            taskIndex,
                            quantity,
                            characterFullName
                        )

                        -- Each task receives credit once for this loot.
                        break
                    end
                end
            end
        end
    end
end