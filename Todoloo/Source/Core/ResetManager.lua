-- *****************************************************************************************************
-- ***** RESET MANAGER
-- *****************************************************************************************************

---Should the group be reset?
---This function is only relevant in the instance where a given group has a reset interval.
---@param group Group Group in question
---@param previousDailyReset integer Previous daily reset time in unix time
---@param previousWeeklyReset integer Previous weekly reset time in unix time
---@return boolean # True if the group should reset, false otherwise
local function ShouldResetGroup(characterName, groupIndex, group, previousDailyReset, previousWeeklyReset)
    local lastResetPerformed = Todoloo.Config.Get(Todoloo.Config.Options.LAST_RESET_PERFORMED)
    if group.reset == TODOLOO_RESET_INTERVALS.Daily and Todoloo.TaskManager:IsGroupComplete(groupIndex, characterName) and lastResetPerformed < previousDailyReset then
        -- reset daily groups
        return true
    elseif group.reset == TODOLOO_RESET_INTERVALS.Weekly and Todoloo.TaskManager:IsGroupComplete(groupIndex, characterName) and lastResetPerformed < previousWeeklyReset then
        -- reset weekly groups
        return true
    end

    return false
end

---Should the task be reset?
---@param task Task Task in question
---@param previousDailyReset integer Previous daily reset time in unix time
---@param previousWeeklyReset integer Previous weekly reset time in unix time
---@return boolean # True if the task should reset, false otherwise
local function ShouldResetTask(task, previousDailyReset, previousWeeklyReset)
    local lastResetPerformed = Todoloo.Config.Get(Todoloo.Config.Options.LAST_RESET_PERFORMED)
    if task.reset == TODOLOO_RESET_INTERVALS.Daily and task.completed and lastResetPerformed < previousDailyReset then
        -- reset daily task
        return true
    elseif task.reset == TODOLOO_RESET_INTERVALS.Weekly and task.completed and lastResetPerformed < previousWeeklyReset then
        -- reset weekly task
        return true
    end

    return false
end

---Perform reset on tasks based on previous reset.
---Loops through all characters groups and tasks to perform account wide task reset.
---@param previousDailyReset integer Previous daily reset time in unix time
---@param previousWeeklyReset integer Previous weekly reset time in unix time
local function PerformResetSince(characters, previousDailyReset, previousWeeklyReset)
    -- if we haven't yet performed a reset since last reset time
    for characterName, character in pairs(characters) do
        for groupIndex, group in pairs(character.groups) do
            if group.reset ~= nil then
                -- group reset interval
                if ShouldResetGroup(characterName, groupIndex, group, previousDailyReset, previousWeeklyReset) then
                    Todoloo.TaskManager:ResetGroup(groupIndex, characterName)
                    Todoloo.Messenger.Message(TODOLOO_L_RESET_MANAGER_GROUP .. " " .. YELLOW_FONT_COLOR:WrapTextInColorCode(group.name ) .. " " .. TODOLOO_L_RESET_MANAGER_ON .. " " .. YELLOW_FONT_COLOR:WrapTextInColorCode(characterName) .. " " .. TODOLOO_L_RESET_MANAGER_HAS_BEEN_RESET)
                end
            else
                -- task reset interval
                for taskIndex, task in pairs(group.tasks) do
                    if ShouldResetTask(task, previousDailyReset, previousWeeklyReset) then
                        Todoloo.TaskManager:ResetTask(groupIndex, taskIndex, characterName)
                        Todoloo.Messenger.Message(TODOLOO_L_RESET_MANAGER_TASK .. " " .. YELLOW_FONT_COLOR:WrapTextInColorCode(task.name) .. " " .. TODOLOO_L_RESET_MANAGER_ON .. " " .. YELLOW_FONT_COLOR:WrapTextInColorCode(characterName) .. " " .. TODOLOO_L_RESET_MANAGER_HAS_BEEN_RESET)
                    end
                end
            end
        end
    end
end

---Get previous reset times
---@return integer previousDailyResetUnixTimestamp Previous daily reset time in unix time
---@return integer previousWeeklyResetUnixTimestamp Previous weekly reset time in unix time
local function GetPreviousResetTimes()
    local serverTime = GetServerTime()

    local dayInSeconds = 24 * 60 * 60
    local weekInSeconds = 7 * 24 * 60 * 60
    local secondsSincePreviousDailyReset = dayInSeconds - C_DateAndTime.GetSecondsUntilDailyReset()
    local secondsSincePreviousWeeklyReset = weekInSeconds - C_DateAndTime.GetSecondsUntilWeeklyReset()
    
    local previousDailyResetUnixTimestamp = serverTime - secondsSincePreviousDailyReset
    local previousWeeklyResetUnixTimestamp = serverTime - secondsSincePreviousWeeklyReset

    return previousDailyResetUnixTimestamp, previousWeeklyResetUnixTimestamp
end

---Perform task reset
function Todoloo.Reset.ResetManager.PerformReset()
    local characters = Todoloo.TaskManager:GetAllCharacters()
    local previousDailyReset, previousWeeklyReset = GetPreviousResetTimes()

    PerformResetSince(characters, previousDailyReset, previousWeeklyReset)
    Todoloo.Config.Set(Todoloo.Config.Options.LAST_RESET_PERFORMED, GetServerTime())

    Todoloo.EventBus
        :RegisterSource(Todoloo.Reset.ResetManager.PerformReset, "reset_manager")
        :TriggerEvent(Todoloo.Reset.ResetManager.PerformReset, Todoloo.Reset.Events.RESET_PERFORMED)
        :UnregisterSource(Todoloo.Reset.ResetManager.PerformReset)
end