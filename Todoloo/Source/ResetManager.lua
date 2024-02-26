Todoloo.ResetManager.Options = {
    LAST_RESET_PERFORMED = "last_reset_performed"
}

-- *****************************************************************************************************
-- ***** SETUP & INITIALIZATION
-- *****************************************************************************************************

function Todoloo.ResetManager.Initialize()
    Todoloo.Debug.Message("Initializing reset manager")
    if TODOLOO_RESET_INFO == nil then
        TODOLOO_RESET_INFO = {}
        TODOLOO_RESET_INFO[Todoloo.ResetManager.Options.LAST_RESET_PERFORMED] = GetServerTime()
    else
        Todoloo.ResetManager.PerformReset()
    end
end

-- *****************************************************************************************************
-- ***** RESET FUNCTIONALITY
-- *****************************************************************************************************

---Should the task be reset?
---@param task Task Task in question
---@param previousDailyReset integer Previous daily reset time in unix time
---@param previousWeeklyReset integer Previous weekly reset time in unix time
---@return boolean shouldReset True if the task should reset, false otherwise
local function ShouldResetTask(task, previousDailyReset, previousWeeklyReset)
    if task.reset == Todoloo.TaskManager.ResetIntervals.Daily and TODOLOO_RESET_INFO[Todoloo.ResetManager.Options.LAST_RESET_PERFORMED] < previousDailyReset then
        -- reset daily task
        Todoloo.Debug.Message("Task '" .. task.name .. "' should reset (daily)")
        return true
    elseif task.reset == Todoloo.TaskManager.ResetIntervals.Weekly and TODOLOO_RESET_INFO[Todoloo.ResetManager.Options.LAST_RESET_PERFORMED] < previousWeeklyReset then
        -- reset weekly task
        Todoloo.Debug.Message("Task '" .. task.name .. "' should reset (weekly)")
        return true
    end

    return false
end

---Perform reset on tasks based on previous reset
---@param previousDailyReset integer Previous daily reset time in unix time
---@param previousWeeklyReset integer Previous weekly reset time in unix time
local function PerformResetSince(groups, previousDailyReset, previousWeeklyReset)
    -- if we haven't yet performed a reset since last daily reset time
    for groupIndex, group in pairs(groups) do
        for taskIndex, task in pairs(group.tasks) do
            if ShouldResetTask(task, previousDailyReset, previousWeeklyReset) then
                Todoloo.TaskManager.ResetTask(groupIndex, taskIndex)
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
    Todoloo.Debug.Message("Last reset performed: " .. date("%d/%m/%y %H:%M:%S", TODOLOO_RESET_INFO[Todoloo.ResetManager.Options.LAST_RESET_PERFORMED]))

    return previousDailyResetUnixTimestamp, previousWeeklyResetUnixTimestamp
end

function Todoloo.ResetManager.PerformReset()
    Todoloo.Debug.Message("Performing reset")
    local groups = Todoloo.TaskManager.GetAll()
    local previousDailyReset, previousWeeklyReset = GetPreviousResetTimes()

    PerformResetSince(groups, previousDailyReset, previousWeeklyReset)
    Todoloo.ResetManager.SetLastResetTime(GetServerTime())

    -- if the tracker frame is visible, we want to refresh it to show the new tasks
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end

function Todoloo.ResetManager.SetLastResetTime(lastResetTime)
    TODOLOO_RESET_INFO[Todoloo.ResetManager.Options.LAST_RESET_PERFORMED] = lastResetTime
end