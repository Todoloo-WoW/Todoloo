--TODO Clean up file

TODOLOO_TASK_TRACKER_MODULE = TodolooTracker_GetModuleInfoTable("TODOLOO_TASK_TRACKER_MODULE")
TODOLOO_TASK_TRACKER_MODULE:SetHeader(TodolooFloatingTrackerFrame.GroupsFrame.TaskHeader, "Todoloo's")

---@class GroupInfo
---@field id integer Index of the group
---@field name string Name of the group
---@field groupRef Group Original saved group
---@field numTasks integer The total number of tasks in the group
---@field numCompletedTasks integer The total number of completed tasks in the group
---@field isComplete boolean Whether every task is complete

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
    group.lineWidth = group:GetWidth()

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

function TODOLOO_TASK_TRACKER_MODULE:BuildGroupInfos()
    return Todoloo.Tasks.BuildTrackerGroupInfos()
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

    local iterTasks = Todoloo.Tasks.BuildTrackerTaskInfos(group.id)

    local showCompletedTasks = Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS)

    for _, taskInfo in ipairs(iterTasks) do
        -- we're intentionally skipping tasks without a name, as we do not want to show these
        if taskInfo and taskInfo.name ~= "" then
            local displayText = Todoloo.Utils.GetTaskDisplayText(taskInfo)
            local task = group.tasks[taskInfo.id]

            if task and task.taskRef ~= taskInfo.taskRef then
                self:FreeTask(group, task)
                task = nil
            end

            if task
                and taskInfo.completed
                and showCompletedTasks
                and task.state == TODOLOO_TRACKER_TASK_STATE_FADING then
                
                self:ResetTaskVisuals(task)

                task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETED
                task.Check:Show()
            end

            -- if the entire group is completed
            if groupCompleted then
                if task then
                    -- process existing tasks
                    task = self:AddTask(group, taskInfo.id, displayText, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                    if not task.state
                        or task.state == TODOLOO_TRACKER_TASK_STATE_PRESENT
                        or task.state == TODOLOO_TRACKER_TASK_STATE_ADDING then

                        task.Glow.Anim:Stop()
                        task.Sheen.Anim:Stop()
                        
                        task.group = group
                        task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETING

                        task.Check:Show()
                        task.Sheen.Anim:Play()
                        task.Glow.Anim:Play()
                        task.CheckFlash.Anim:Play()
                    end
                elseif Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                    -- if the player want to display completed tasks, add those which are not yet displayed
                    task = self:AddTask(group, taskInfo.id, displayText, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                    task.Check:Show()
                    task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETED
                end
            else
                -- if the task is completed
                if taskInfo.completed then
                    if task then
                        task = self:AddTask(group, taskInfo.id, displayText, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                        if not task.state
                            or task.state == TODOLOO_TRACKER_TASK_STATE_PRESENT
                            or task.state == TODOLOO_TRACKER_TASK_STATE_ADDING then

                            task.Glow.Anim:Stop()
                            task.Sheen.Anim:Stop()
                            
                            task.group = group
                            task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETING

                            task.Check:Show()
                            task.Sheen.Anim:Play()
                            task.Glow.Anim:Play()
                            task.CheckFlash.Anim:Play()
                        end
                    elseif Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                        -- task is not shown in the task tracker - add it without animation
                        task = self:AddTask(group, taskInfo.id, displayText, TASK_TYPE, useFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
                        task.Check:Show()
                        task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETED
                    end
                else
                    if existingGroup and not task then
                        -- task it nos shown in the task tracker - add it and begin adding animation
                        task = self:AddTask(group, taskInfo.id, displayText, TASK_TYPE, useFullHeight)
                        task.Check:Hide()
                        task.Sheen.Anim:Play()
                        task.Glow.Anim:Play()
                        task.state = TODOLOO_TRACKER_TASK_STATE_ADDING
                    elseif task then
                        if task.state ~= TODOLOO_TRACKER_TASK_STATE_PRESENT
                            and task.state ~= TODOLOO_TRACKER_TASK_STATE_ADDING then
                            self:ResetTaskVisuals(task)
                        end

                        task = self:AddTask(group, taskInfo.id, displayText, TASK_TYPE, useFullHeight)
                        
                        task.Check:Hide()
                    else
                        -- group not existing - add the task
                        task = self:AddTask(group, taskInfo.id, displayText, TASK_TYPE, useFullHeight)
                    end
                end
            end
            if task then
                task.group = group
                task.taskRef = taskInfo.taskRef
                self:UpdateTaskHighlight(task)

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

function TODOLOO_TASK_TRACKER_MODULE:FitGroupToHeight(group)
    local header = self.Header
    if header and header.added then
        header = nil
    end

    -- Keep the entire group when it already fits.
    if TodolooTracker_CanFitGroup(group, header) then
        return true, false
    end

    local originalHeight = group.height
    local visibleHeight = group.HeaderText:GetHeight()

    group.height = visibleHeight

    -- Even the group title must fit.
    if not TodolooTracker_CanFitGroup(group, header) then
        group.height = originalHeight
        return false, true
    end

    local lastVisibleTask
    local overflow = false
    local needsRefresh = false

    for _, task in ipairs(group.layoutTasks) do
        if not overflow then
            group.height = visibleHeight
                + task:GetHeight()
                + self.taskSpacing

            if TodolooTracker_CanFitGroup(group, header) then
                visibleHeight = group.height
                lastVisibleTask = task
            else
                overflow = true
            end
        end

        if overflow then
            task.used = nil

            -- Freeing these rows stops their animations. Request another
            -- layout so completion summaries can advance without them.
            if task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETING
                or task.state == TODOLOO_TRACKER_TASK_STATE_FADING then
                needsRefresh = true
            end
        end
    end

    group.height = visibleHeight
    group.currentTask = lastVisibleTask

    if needsRefresh then
        TodolooTracker_Update()
    end

    return true, overflow
end

function TODOLOO_TASK_TRACKER_MODULE:UpdateSingle(groupInfo)
    -- we're not adding groups without a name
    if groupInfo.name == "" then
        return
    end

    local useFullHeight = true -- always use full height
    
    local existingGroup = self:GetExistingGroup(groupInfo.id)

    if existingGroup and existingGroup.groupRef ~= groupInfo.groupRef then
        self:FreeGroup(existingGroup)
        existingGroup = nil
    end

    local isComplete = groupInfo.isComplete
    local group = self:GetGroup(groupInfo.id)

    group.groupRef = groupInfo.groupRef

    local showGroupProgress = Todoloo.Config.Get(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT)

    self:SetGroupHeader(group, groupInfo.name, groupInfo.id, showGroupProgress, groupInfo.numTasks, groupInfo.numCompletedTasks)

    if isComplete and not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        local groupCompleting = TodolooTaskTracker_DoTasks(self, group, isComplete, existingGroup, useFullHeight)
        -- wait for animations to finish
        if not groupCompleting then
            -- if the player does not want to see completed tasks tell them we're done with this group
            if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS) then                
                local forceCompletedToUseFullHeight = true
                self:AddTask(group, "GroupComplete", TODOLOO_L_TASK_TRACKER_GROUP_COMPLETE, nil, forceCompletedToUseFullHeight, TODOLOO_TRACKER_DASH_STYLE_HIDE, TODOLOO_TRACKER_COLOR["Complete"])
            end
        end
    else
        TodolooTaskTracker_DoTasks(self, group, isComplete, existingGroup, useFullHeight)
    end

    local fits, overflow = self:FitGroupToHeight(group)

    group:SetHeight(group.height)

    if fits and TodolooTracker_AddGroup(group) then
        group:Show()
        self:FreeUnusedTasks(group)

        if overflow then
            self.hasOverflow = true
            return true
        end
    else
        self.hasOverflow = true
        group.used = false
        return true
    end
end

function TODOLOO_TASK_TRACKER_MODULE:Update()
    self:BeginLayout()

    self:EnumGroupData(self.UpdateSingle)

    self:EndLayout()
end