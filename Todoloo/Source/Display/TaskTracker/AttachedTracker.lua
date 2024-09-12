---@class Todoloo
local Todoloo = select(2, ...);

-- *****************************************************************************************************
-- ***** TODOLOO OBJECTIVE TRACKER
-- *****************************************************************************************************

local settings = {
    headerText = "Todoloo's",
    events = { },
    lineTemplate = "TodolooObjectiveTaskTemplate",
    blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
    rightEdgeFrameSpacing = 2,
    uiOrder = 99
};

TodolooObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function TodolooObjectiveTrackerMixin:InitModule()
    Todoloo.EventBus:RegisterEvents(self, {
        Todoloo.Tasks.Events.GROUP_ADDED,
        Todoloo.Tasks.Events.GROUP_REMOVED,
        Todoloo.Tasks.Events.GROUP_RESET,
        Todoloo.Tasks.Events.GROUP_UPDATED,
        Todoloo.Tasks.Events.GROUP_MOVED,
        Todoloo.Tasks.Events.TASK_ADDED,
        Todoloo.Tasks.Events.TASK_COMPLETION_SET,
        Todoloo.Tasks.Events.TASK_REMOVED,
        Todoloo.Tasks.Events.TASK_RESET,
        Todoloo.Tasks.Events.TASK_UPDATED,
        Todoloo.Tasks.Events.TASK_MOVED,
        Todoloo.Reset.Events.RESET_PERFORMED,
        Todoloo.Config.Events.CONFIG_CHANGED
    }, self.OnEvent);
end

function TodolooObjectiveTrackerMixin:OnEvent(event, ...)
    self:MarkDirty();
end

function TodolooObjectiveTrackerMixin:ShouldDisplayGroup(group)
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS) then
        return true;
    end

    for _, task in pairs(group.tasks) do
        if not task.completed then
            return true;
        end
    end

    return false;
end

function TodolooObjectiveTrackerMixin:BuildGroupInfos()
    local infos = {};

    for index, group in pairs(Todoloo.TaskManager:GetAllGroups()) do
        if self:ShouldDisplayGroup(group) then
            local numCompletedTasks = 0;
            for _, task in ipairs(group.tasks) do
                if task.completed then
                    numCompletedTasks = numCompletedTasks + 1;
                end
            end

            tinsert(infos, { name = group.name, id = index, numTasks = #group.tasks, numCompletedTasks = numCompletedTasks });
        end
    end

    return infos;
end

function TodolooObjectiveTrackerMixin:EnumGroupData(func)
    local groups = self:BuildGroupInfos();
    for _, group in ipairs(groups) do
        if func(self, group) then
            return;
        end
    end
end

function TodolooObjectiveTrackerMixin:DoTasks(block, groupCompleted, isExistingBlock, useFullHeight)
    local taskCompleting = false;

    local tasks = Todoloo.TaskManager:GetGroupTasks(block.id);
    local iterTasks = {};
    for index, task in ipairs(tasks) do
        task["id"] = index;
        tinsert(iterTasks, task);
    end

    if Todoloo.Config.Get(Todoloo.Config.Options.ORDER_BY_COMPLETION) then
        table.sort(iterTasks, function(lhs, rhs)
            return not lhs.completed and rhs.completed;
        end);
    end

    for _, task in pairs(iterTasks) do
        local line = block:GetExistingLine(task.id);
        if groupCompleted then
            if line and line.state ~= ObjectiveTrackerAnimLineState.Faded then
                line = block:AddObjective(task.id, task.name, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
                if not line.state or line.state == ObjectiveTrackerAnimLineState.Present then
                    line:SetState(ObjectiveTrackerAnimLineState.Completing);
                end
            elseif Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                line = block:AddObjective(task.id, task.name, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
                line:SetState(ObjectiveTrackerAnimLineState.Completed);
            end
        else
            if task.completed then
                if line and line.state == ObjectiveTrackerAnimLineState.Faded then
                    -- Don't show this task anymore.
                elseif line then
                    line = block:AddObjective(task.id, task.name, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
                    if not line.state or line.state == ObjectiveTrackerAnimLineState.Present then
                        line:SetState(ObjectiveTrackerAnimLineState.Completing);
                    end
                else
                    line = block:AddObjective(task.id, task.name, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"])
                    line:SetState(ObjectiveTrackerAnimLineState.Completed);
                end
            else
                if not taskCompleting then
                    if isExistingBlock and not line then
                        line = block:AddObjective(task.id, task.name, nil, useFullHeight);
                        line:SetState(ObjectiveTrackerAnimLineState.Adding);
                    else
                        line = block:AddObjective(task.id, task.name, nil, useFullHeight);
                        if line.state == ObjectiveTrackerAnimLineState.Completed then
                            line:SetState(ObjectiveTrackerAnimLineState.Present);
                        end
                    end
                end
            end
        end

        if line then
            if line.state == ObjectiveTrackerAnimLineState.Completing then
                taskCompleting = true;
            end
        end
    end

    if groupCompleted and not taskCompleting and not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        block:ForEachUsedLine(function(line, taskKey)
            if line.state == ObjectiveTrackerAnimLineState.Completed then
                line:SetState(ObjectiveTrackerAnimLineState.Fading);
            end
        end);
    end

    return taskCompleting;
end

function TodolooObjectiveTrackerMixin:UpdateSingle(group)
    -- Groups without names should not be visible.
    if group.name == "" then
        return;
    end

    local useFullHeight = true;
    local isComplete = Todoloo.TaskManager:IsGroupComplete(group.id);
    local block, isExistingBlock = self:GetBlock(group.id);

    local groupHeaderText = group.name;
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT) then
        local groupProgressText = " (" .. group.numCompletedTasks .. "/" .. group.numTasks .. ")";
        groupHeaderText = groupHeaderText .. groupProgressText;
    end

    block:SetHeader(groupHeaderText);

    if isComplete and not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        local taskCompleting = self:DoTasks(block, isComplete, isExistingBlock, useFullHeight);
        if not taskCompleting then
            if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS) then
                block:AddObjective("GROUP_COMPLETE", "Group tasks done", nil, true, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
            end
        end
    else
        self:DoTasks(block, isComplete, isExistingBlock, useFullHeight);
    end

    self:LayoutBlock(block);
end

function TodolooObjectiveTrackerMixin:LayoutContents()
    if Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
        self:EnumGroupData(self.UpdateSingle);
    end
end

-- *****************************************************************************************************
-- ***** TODOLOO OBJECTIVE TASK
-- *****************************************************************************************************

TodolooObjectiveTaskMixin = CreateFromMixins(ObjectiveTrackerAnimLineMixin);

function TodolooObjectiveTaskMixin:OnGlowAnimFinished()
    if self.state == ObjectiveTrackerAnimLineState.Completing then
        if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
            self.state = ObjectiveTrackerAnimLineState.Completed;
            self:UpdateModule();
        else
            self:SetState(ObjectiveTrackerAnimLineState.Fading);
        end
    else
        ObjectiveTrackerAnimLineMixin.OnGlowAnimFinished(self);
    end
end

function TodolooObjectiveTaskMixin:OnClick()
    local textColorStyle = OBJECTIVE_TRACKER_COLOR["Normal"];
    self.Text:SetTextColor(textColorStyle.r, textColorStyle.g, textColorStyle.b);

    if IsShiftKeyDown() then
        if self.objectiveKey == "GROUP_COMPLETE" then
            return;
        end

        if self.state and self.state == ObjectiveTrackerAnimLineState.Completing then
            return;
        end

        local groupId = self.parentBlock.id;
        local id = self.objectiveKey;

        local task = Todoloo.TaskManager:GetTask(groupId, id);
        Todoloo.TaskManager:SetTaskCompletion(groupId, id, not task.completed);
    end
end

function TodolooObjectiveTaskMixin:OnEnter()
    if self.objectiveKey == "GROUP_COMPLETE" then
        return
    end

    local textColorStyle = OBJECTIVE_TRACKER_COLOR["NormalHighlight"];
    self.Text:SetTextColor(textColorStyle.r, textColorStyle.g, textColorStyle.b);
end

function TodolooObjectiveTaskMixin:OnLeave()
    if self.objectiveKey == "GROUP_COMPLETE" then
        return
    end

    local textColorStyle = OBJECTIVE_TRACKER_COLOR["Normal"];
    
    if self.state == ObjectiveTrackerAnimLineState.Completed or self.state == ObjectiveTrackerAnimLineState.Completing then
        textColorStyle = OBJECTIVE_TRACKER_COLOR["Complete"];
    end

    self.Text:SetTextColor(textColorStyle.r, textColorStyle.g, textColorStyle.b);
end