--TODO Clean up file

TODOLOO_TASK_TRACKER_MODULE = TodolooTracker_GetModuleInfoTable("TODOLOO_TASK_TRACKER_MODULE")
TODOLOO_TASK_TRACKER_MODULE:SetHeader(TodolooFloatingTrackerFrame.GroupsFrame.TaskHeader, "Todoloo's")

---@class GroupInfo
---@field name string Name of the group
---@field id integer Index of the group
---@field numTasks integer The total number of tasks in the group
---@field numCompletedTasks integer The total number of completed tasks in the group

local TASK_TYPE = { template = "TodolooTrackerTaskTemplate", freeTasks = {} }

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

---Set header of the group
---@param group Frame Group frame
---@param text string String value to set
---@param id integer Group ID
---@param showGroupProgress boolean Should we show group progress?
---@param numTasks integer The total number of tasks in the group
---@param numCompletedTasks integer The total number of completed tasks in the group
function TODOLOO_TASK_TRACKER_MODULE:SetGroupHeader(group, text, id, showGroupProgress, numTasks, numCompletedTasks)
    group.rightButton = nil
    group.lineWidth = TODOLOO_TRACKER_TEXT_WIDTH

    -- set text
    group.HeaderText:SetWidth(group.lineWidth)

    if showGroupProgress then
        -- set group progress
        local groupProgressText = " (" .. numCompletedTasks .. "/" .. numTasks .. ")"
        text = text .. groupProgressText
    end

    local height = self:SetStringText(group.HeaderText, text, nil, TODOLOO_TRACKER_COLOR["Header"])
    group.height = height
end

---Build info tables of all groups
---@return GroupInfo[] groupInfos
function TODOLOO_TASK_TRACKER_MODULE:BuildGroupInfos()
    local infos = {}

    for index, group in pairs(Todoloo.TaskManager:GetAllGroups()) do
        if self:ShouldDisplayGroup(group) then
            local numCompletedTasks = 0
            for _, task in ipairs(group.tasks) do
                if task.completed then
                    numCompletedTasks = numCompletedTasks + 1
                end
            end

            table.insert(infos, { name = group.name, id = index, numTasks = #group.tasks, numCompletedTasks = numCompletedTasks})
        end
    end

    --TODO: Sort table?
    return infos
end

---TODO: Add documentation
---@param func any
function TODOLOO_TASK_TRACKER_MODULE:EnumGroupData(func)
    local groupInfos = self:BuildGroupInfos()
    for _, groupInfo in ipairs(groupInfos) do
        if func(self, groupInfo) then
            -- if we're out of free groups
            return
        end
    end
end

---Run through each task in the group and set correct state
---@param self any
---@param group Frame
---@param groupCompleted boolean
---@param existingGroup Frame
---@param useFullHeight boolean
local function TodolooTaskTracker_DoTasks(self, group, groupCompleted, existingGroup, useFullHeight)
    local completing = false

    local tasks = Todoloo.TaskManager:GetGroupTasks(group.id)
    local iterTasks = {}
    for index, task in ipairs(tasks) do
        task["id"] = index
        table.insert(iterTasks, task)
    end

    if Todoloo.Config.Get(Todoloo.Config.Options.ORDER_BY_COMPLETION) then
        table.sort(iterTasks, function(first, second) return not first.completed and second.completed end)
    end

    for _, taskInfo in pairs(iterTasks) do
        -- we're intentionally skipping tasks without a name, as we do not want to show these
        if taskInfo and taskInfo.name ~= "" then
            local task = group.tasks[taskInfo.id]
            -- if the entire group is completed
            if groupCompleted then
                if task then
                    -- process existing tasks
                    task = self:AddTask(group, taskInfo.id, taskInfo.name, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                    if not task.state or  task.state == TODOLOO_TRACKER_TASK_STATE_PRESENT then
                        -- this task has not yet been market as completed
                        task.group = group
                        task.Check:Show()
                        task.Sheen.Anim:Play()
                        task.Glow.Anim:Play()
                        task.CheckFlash.Anim:Play()
                        task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETING
                    end
                elseif Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                    -- if the player want to display completed tasks, add those which are not yet displayed
                    task = self:AddTask(group, taskInfo.id, taskInfo.name, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                    task.Check:Show()
                    task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETED
                end
            else
                -- if the task is completed
                if taskInfo.completed then
                    if task then
                        task = self:AddTask(group, taskInfo.id, taskInfo.name, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                        if not task.state or task.state == TODOLOO_TRACKER_TASK_STATE_PRESENT then
                            -- task is shown in the task tracker - begin completion animation
                            task.group = group
                            task.Check:Show()
                            task.Sheen.Anim:Play()
                            task.Glow.Anim:Play()
                            task.CheckFlash.Anim:Play()
                            task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETING
                        end
                    elseif Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                        -- task is not shown in the task tracker - add it without animation
                        task = self:AddTask(group, taskInfo.id, taskInfo.name, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                        task.Check:Show()
                        task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETED
                    end
                else
                    if existingGroup and not task then
                        -- task it nos shown in the task tracker - add it and begin adding animation
                        task = self:AddTask(group, taskInfo.id, taskInfo.name, TASK_TYPE, useFullHeight)
                        task.Check:Hide()
                        task.Sheen.Anim:Play()
                        task.Glow.Anim:Play()
                        task.state = TODOLOO_TRACKER_TASK_STATE_ADDING
                    elseif task then
                        -- task is already shown - add the task
                        task = self:AddTask(group, taskInfo.id, taskInfo.name, TASK_TYPE, useFullHeight)
                        task.Check:Hide()
                        task.state = TODOLOO_TRACKER_TASK_STATE_PRESENT
                    else
                        -- group not existing - add the task
                        task = self:AddTask(group, taskInfo.id, taskInfo.name, nil, useFullHeight)
                    end
                end
            end
            if task then
                task.group = group
                if task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETING then
                    completing = true
                end
            end
        end
    end

    if not completing then --groupCompleted and
        if not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
            for _, task in pairs(group.tasks) do
                -- only trigger the task fade out animation, if the player do not want to see their completed tasks    
                if task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETED then
                    task.FadeOutAnim:Play()
                    task.state = TODOLOO_TRACKER_TASK_STATE_FADING
                end
            end 
        end
    end

    return completing
end

---Update single group and underlying tasks
---@param groupInfo GroupInfo Group info
function TODOLOO_TASK_TRACKER_MODULE:UpdateSingle(groupInfo)
    -- we're not adding groups without a name
    if groupInfo.name == "" then
        return
    end

    local useFullHeight = true -- always use full height
    local existingGroup = self:GetExistingGroup(groupInfo.id)
    local isComplete = Todoloo.TaskManager:IsGroupComplete(groupInfo.id)
    local group = self:GetGroup(groupInfo.id)
    local showGroupProgress = Todoloo.Config.Get(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT)

    self:SetGroupHeader(group, groupInfo.name, groupInfo.id, showGroupProgress, groupInfo.numTasks, groupInfo.numCompletedTasks)

    if isComplete and not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        local groupCompleting = TodolooTaskTracker_DoTasks(self, group, isComplete, existingGroup, useFullHeight)
        -- wait for animations to finish
        if not groupCompleting then
            -- if the player does not want to see completed tasks tell them we're done with this group
            if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS) then
                local completionText = "Group tasks done" --TODO: Add localization, hence the below if-statement
                if completionText then
                    local forceCompletedToUseFullHeight = true
                    self:AddTask(group, "GroupComplete", completionText, nil, forceCompletedToUseFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                end
            end
        end
    else
        TodolooTaskTracker_DoTasks(self, group, isComplete, existingGroup, useFullHeight)
    end

    group:SetHeight(group.height)

    if TodolooTracker_AddGroup(group) then
        group:Show()
        self:FreeUnusedTasks(group)
    else
        group.used = false
        return true
    end
end

function TODOLOO_TASK_TRACKER_MODULE:Update()
    self:BeginLayout()

    self:EnumGroupData(self.UpdateSingle)

    self:EndLayout()
end

---Should the group be displayed in the task tracker?
---@param group Group Group in question
---@return boolean display Whether or not the group should be displayed 
function TODOLOO_TASK_TRACKER_MODULE:ShouldDisplayGroup(group)
    -- if player configuration should always display completed tasks
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS) then
        return true
    end

    -- if any of the tasks have not yet been completed, show the group
    for _, task in pairs(group.tasks) do
        if not task.completed then
            return true
        end
    end

    -- if none of the above, hide the group
    return false
end