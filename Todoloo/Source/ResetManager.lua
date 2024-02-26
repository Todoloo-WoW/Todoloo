-- *****************************************************************************************************
-- ***** RESET FUNCTIONALITY
-- *****************************************************************************************************

---Should the task be reset?
---@param task Task Task in question
---@param previousDailyReset integer Previous daily reset time in unix time
---@param previousWeeklyReset integer Previous weekly reset time in unix time
---@return boolean # True if the task should reset, false otherwise
local function ShouldResetTask(task, previousDailyReset, previousWeeklyReset)
    local lastResetPerformed = Todoloo.Config.Get(Todoloo.Config.Options.LAST_RESET_PERFORMED)
    if task.reset == Todoloo.TaskManager.ResetIntervals.Daily and lastResetPerformed < previousDailyReset then
        -- reset daily task
        Todoloo.Debug.Message("Task '" .. task.name .. "' should reset (daily)")
        return true
    elseif task.reset == Todoloo.TaskManager.ResetIntervals.Weekly and lastResetPerformed < previousWeeklyReset then
        -- reset weekly task
        Todoloo.Debug.Message("Task '" .. task.name .. "' should reset (weekly)")
        return true
    end

    return false
end

---Perform reset on tasks based on previous reset.
---Loops through all characters groups and tasks to perform account wide task reset.
---@param previousDailyReset integer Previous daily reset time in unix time
---@param previousWeeklyReset integer Previous weekly reset time in unix time
local function PerformResetSince(characters, previousDailyReset, previousWeeklyReset)
    -- if we haven't yet performed a reset since last daily reset time
    for characterName, character in pairs(characters) do
        for groupIndex, group in pairs(character.groups) do
            for taskIndex, task in pairs(group.tasks) do
                if ShouldResetTask(task, previousDailyReset, previousWeeklyReset) then
                    Todoloo.TaskManager.ResetTask(groupIndex, taskIndex, characterName)
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

    Todoloo.Debug.Message("Previous daily reset: " .. date("%d/%m/%y %H:%M:%S", previousDailyResetUnixTimestamp))
    Todoloo.Debug.Message("Previous weekly reset: " .. date("%d/%m/%y %H:%M:%S", previousWeeklyResetUnixTimestamp))
    Todoloo.Debug.Message("Last reset performed: " .. date("%d/%m/%y %H:%M:%S", Todoloo.Config.Get(Todoloo.Config.Options.LAST_RESET_PERFORMED)))

    return previousDailyResetUnixTimestamp, previousWeeklyResetUnixTimestamp
end

---Perform task reset
function Todoloo.ResetManager.PerformReset()
    local characters = Todoloo.TaskManager.GetAllCharacters()
    local previousDailyReset, previousWeeklyReset = GetPreviousResetTimes()

    PerformResetSince(characters, previousDailyReset, previousWeeklyReset)
    Todoloo.Config.Set(Todoloo.Config.Options.LAST_RESET_PERFORMED, GetServerTime())

    -- if the tracker frame is visible, we want to refresh it to show the new tasks
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end