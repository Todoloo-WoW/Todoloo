local settings = {
    headerText = "Todoloo's",
    events = { },
    lineTemplate = "TodolooObjectiveTaskTemplate",
    blockTemplate = "TodolooObjectiveBlockTemplate",
    rightEdgeFrameSpacing = 2,
    uiOrder = 99
};

TodolooObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function TodolooObjectiveTrackerMixin:AcquireFrame(template)
    local pool = self.framePools:GetOrCreatePool("Frame", self.ContentsFrame, template)

    local frame, isNew = pool:Acquire()
    frame.template = template
    frame:SetParent(self.ContentsFrame)

    return frame, isNew
end

function TodolooObjectiveTrackerMixin:ReleaseFrame(frame)
    self.framePools:Release(frame)
end

function TodolooObjectiveTrackerMixin:FreeBlock(block)
    self:RemoveBlockFromCache(block, true)
    block:Free()

    block.groupRef = nil
    block.isHighlighted = false

    self.usedBlocks[block.template][block.id] = nil

    self:ReleaseFrame(block)
    self:OnFreeBlock(block)
end

function TodolooObjectiveTrackerMixin:GetContextMenuParent()
    return self.parentContainer
end

function TodolooObjectiveTrackerMixin:InitModule()
    self.framePools = CreateFramePoolCollection()

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

function TodolooObjectiveTrackerMixin:BuildGroupInfos()
    return Todoloo.Tasks.BuildTrackerGroupInfos()
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

    local iterTasks = Todoloo.Tasks.BuildTrackerTaskInfos(block.id)
    local showCompletedTasks = Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS)

    for _, task in ipairs(iterTasks) do
        local displayText = Todoloo.Utils.GetTaskDisplayText(task)
        local line = block:GetExistingLine(task.id);

        if line and line.taskRef ~= task.taskRef then
            block:FreeLine(line)
            line = nil
        end

        if line and task.completed and showCompletedTasks then
            if line.state == ObjectiveTrackerAnimLineState.Fading
                or line.state == ObjectiveTrackerAnimLineState.Faded then
                
                line:ResetTaskVisuals()
                line:SetState(ObjectiveTrackerAnimLineState.Completed)
            end
        end

        if groupCompleted then
            if line and line.state ~= ObjectiveTrackerAnimLineState.Faded then
                line = block:AddObjective(task.id, displayText, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
                if not line.state
                    or line.state == ObjectiveTrackerAnimLineState.Present
                    or line.state == ObjectiveTrackerAnimLineState.Adding then
                    
                    line.GlowAnim:Stop()
                    line:SetState(ObjectiveTrackerAnimLineState.Completing);
                end
            elseif Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
                line = block:AddObjective(task.id, displayText, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
                line:SetState(ObjectiveTrackerAnimLineState.Completed);
            end
        else
            if task.completed then
                if line and line.state == ObjectiveTrackerAnimLineState.Faded then
                    -- Don't show this task anymore.
                elseif line then
                    line = block:AddObjective(task.id, displayText, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
                    if not line.state
                        or line.state == ObjectiveTrackerAnimLineState.Present
                        or line.state == ObjectiveTrackerAnimLineState.Adding then
                        
                        line.GlowAnim:Stop()
                        line:SetState(ObjectiveTrackerAnimLineState.Completing);
                    end
                elseif showCompletedTasks then
                    line = block:AddObjective(task.id, displayText, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"])
                    line:SetState(ObjectiveTrackerAnimLineState.Completed);
                end
            else
                if line then
                    if line.state ~= ObjectiveTrackerAnimLineState.Present
                        and line.state ~= ObjectiveTrackerAnimLineState.Adding then
                        line:ResetTaskVisuals()
                    end

                    line = block:AddObjective(task.id, displayText, nil, useFullHeight);
                else
                    line = block:AddObjective(task.id, displayText, nil, useFullHeight);
                    if isExistingBlock then
                        line:SetState(ObjectiveTrackerAnimLineState.Adding);
                    else
                        line:SetState(ObjectiveTrackerAnimLineState.Present);
                    end
                end
            end
        end

        if line then
            line.taskRef = task.taskRef
            line:UpdateTaskHighlight()

            if line.state == ObjectiveTrackerAnimLineState.Completing then
                taskCompleting = true;
            end
        end
    end

    if not taskCompleting and not showCompletedTasks then
        block:ForEachUsedLine(function(line)
            if line.used and line.state == ObjectiveTrackerAnimLineState.Completed then
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
    local isComplete = group.isComplete
    
    local existingBlock = self:GetExistingBlock(group.id)

    if existingBlock and existingBlock.groupRef ~= group.groupRef then
        self:FreeBlock(existingBlock)
    end

    local block, isExistingBlock = self:GetBlock(group.id)
    block.groupRef = group.groupRef

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
                block:AddObjective("GROUP_COMPLETE", TODOLOO_L_TASK_TRACKER_GROUP_COMPLETE, nil, true, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
            end
        end
    else
        self:DoTasks(block, isComplete, isExistingBlock, useFullHeight);
    end

    return not self:LayoutBlock(block);
end

function TodolooObjectiveTrackerMixin:LayoutContents()
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) and Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
        self:EnumGroupData(self.UpdateSingle);
    end
end

TodolooObjectiveTaskMixin = CreateFromMixins(ObjectiveTrackerAnimLineMixin);

function TodolooObjectiveTaskMixin:ResetTaskVisuals()
    self.GlowAnim:Stop()
    self.CheckAnim:Stop()
    self.FadeOutAnim:Stop()
    self.FadeInAnim:Stop()

    self:SetAlpha(1)
    self.Icon:SetAlpha(1)
    self.Glow:SetAlpha(0)
    self.CheckGlow:SetAlpha(0)

    self:SetState(ObjectiveTrackerAnimLineState.Present)
end

function TodolooObjectiveTaskMixin:OnGlowAnimFinished()
    local block = self.parentBlock

    if not block or block:GetExistingLine(self.objectiveKey) ~= self then
        return
    end

    if self.state == ObjectiveTrackerAnimLineState.Adding then
        ObjectiveTrackerAnimLineMixin.OnGlowAnimFinished(self)
        return
    end

    if self.state ~= ObjectiveTrackerAnimLineState.Completing then
        return
    end

    local task = Todoloo.Tasks.ResolveTrackerTask(
        block.id,
        self.objectiveKey,
        self.taskRef
    )

    if not task or not task.completed then
        self:UpdateModule()
        return
    end

    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        self:SetState(ObjectiveTrackerAnimLineState.Completed)
        self:UpdateModule()
    else
        self:SetState(ObjectiveTrackerAnimLineState.Fading)
    end
end

function TodolooObjectiveTaskMixin:OnFadeOutAnimFinished()
    local block = self.parentBlock

    if not block or block:GetExistingLine(self.objectiveKey) ~= self then
        return
    end

    if self.state ~= ObjectiveTrackerAnimLineState.Fading then
        return
    end

    local task = Todoloo.Tasks.ResolveTrackerTask(
        block.id,
        self.objectiveKey,
        self.taskRef
    )

    if not task then
        self:UpdateModule()
        return
    end

    if not task.completed
        or Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then

        self:ResetTaskVisuals()

        if task.completed then
            self:SetState(ObjectiveTrackerAnimLineState.Completed)
        end

        self:UpdateModule()
        return
    end

    ObjectiveTrackerAnimLineMixin.OnFadeOutAnimFinished(self)
end

function TodolooObjectiveTaskMixin:OnClick(mouseButton)
    if mouseButton ~= "LeftButton" then
        return
    end

    local amount
    if IsControlKeyDown() then
        amount = -1
    elseif IsShiftKeyDown() then
        amount = 1
    else
        return
    end

    if self.objectiveKey == "GROUP_COMPLETE" then
        return
    end

    if self.state == ObjectiveTrackerAnimLineState.Completing then
        return
    end

    local groupId = self.parentBlock.id

    if not Todoloo.Tasks.ResolveTrackerTask(groupId, self.objectiveKey, self.taskRef) then
        self:UpdateModule()
        return
    end

    Todoloo.TaskManager:AdjustTaskProgress(groupId, self.objectiveKey, amount)
end

function TodolooObjectiveTaskMixin:OnEnter()
    if self.objectiveKey == "GROUP_COMPLETE" then
        return
    end

    self.isHighlighted = true
    self:UpdateTaskHighlight()

    local taskInfo = Todoloo.Tasks.ResolveTrackerTask(self.parentBlock.id, self.objectiveKey, self.taskRef)

    Todoloo.Utils.ShowTaskTooltip(self, taskInfo)
end

function TodolooObjectiveTaskMixin:OnLeave()
    Todoloo.Utils.HideTaskTooltip(self)

    self.isHighlighted = nil
    self:UpdateTaskHighlight()
end

function TodolooObjectiveTaskMixin:UpdateTaskHighlight()
    if self.objectiveKey == "GROUP_COMPLETE" then
        return
    end

    local completed = self.taskRef and self.taskRef.completed
    local highlighted = self.isHighlighted or (self.parentBlock and self.parentBlock.isHighlighted)

    local colorStyle = OBJECTIVE_TRACKER_COLOR[completed and "Complete" or "Normal"]

    if highlighted and colorStyle.reverse then
        colorStyle = colorStyle.reverse
    end

    self.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
    self.Text.colorStyle = colorStyle

    if self.Dash then
        local dashColor = OBJECTIVE_TRACKER_COLOR[highlighted and "NormalHighlight" or "Normal"]

        self.Dash:SetTextColor(dashColor.r, dashColor.g, dashColor.b)
    end
end

TodolooObjectiveBlockMixin = {}

function TodolooObjectiveBlockMixin:GetLine(objectiveKey, optTemplate)
    local module = self.parentModule
    local template = optTemplate or module.lineTemplate
    local line = self:GetExistingLine(objectiveKey)

    if line and line.template ~= template then
        self:FreeLine(line)
        line = nil
    end

    if not line then
        line = module:AcquireFrame(template)
        line:SetParent(self)

        line.taskRef = nil
        line.isHighlighted = nil
        line:SetAlpha(1)
        line.Icon:Hide()
        line.Icon:SetAlpha(1)
        line.Text.colorStyle = nil
        line.dashStyle = nil

        line:Show()
    end

    self.usedLines[objectiveKey] = line

    line.objectiveKey = objectiveKey
    line.parentBlock = self
    line.used = true

    return line
end

function TodolooObjectiveBlockMixin:FreeLine(line)
    self.usedLines[line.objectiveKey] = nil

    self.parentModule:ReleaseFrame(line)
    line:Hide()

    if line.OnFree then
        line:OnFree(self)
    end

    line.taskRef = nil
end

TodolooAttachedTrackerContainerMixin = {}

function TodolooAttachedTrackerContainerMixin:Initialize()
    if self.module then
        return
    end

    self.module = TodolooObjectiveTracker
    self.module:SetContainer(self)
    self:MarkDirty()
end

function TodolooAttachedTrackerContainerMixin:MarkDirty()
    self.dirty = true
end

function TodolooAttachedTrackerContainerMixin:IsCollapsed()
    return false
end

function TodolooAttachedTrackerContainerMixin:ForceExpand()
    self:MarkDirty()
end

function TodolooAttachedTrackerContainerMixin:OnUpdate(elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed

    if not self.dirty and self.elapsed < 0.1 then
        return
    end

    self.elapsed = 0
    self:Refresh()
end

function TodolooAttachedTrackerContainerMixin:Refresh()
    local module = self.module
    local tracker = ObjectiveTrackerFrame

    if not module then
        return
    end

    if not tracker or not tracker.init or not tracker:GetTop() then
        module:Hide()
        self.wasSupressed = true
        self.dirty = false
        return
    end

    local spacing = tracker.moduleSpacing or 10
    local nativeHeight = 0
    local hasNativeContents = false

    tracker:ForEachModule(function(nativeModule)
        local height = nativeModule:GetContentsHeight()

        if height > 0 then
            if hasNativeContents then
                nativeHeight = nativeHeight + spacing
            end

            nativeHeight = nativeHeight + height
            hasNativeContents = true
        end
    end)

    local suppressed = tracker:IsCollapsed()
        or not tracker:ShouldShowHeader()
        or (hasNativeContents and not tracker:IsVisible())

    if suppressed then
        module:Hide()
        self.wasSupressed = true
        self.dirty = false
        return
    end

    local offset = (tracker.topModulePadding or 0) + nativeHeight

    if hasNativeContents then
        offset = offset + spacing
    end

    local width = tracker:GetWidth()
    local scale = tracker:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local availableHeight = math.max(0, tracker:GetHeight() - offset)

    if self.lastScale ~= scale then
        self:SetScale(scale)
        self.lastScale = scale
        self.dirty = true
    end

    if self.lastWidth ~= width then
        self:SetWidth(width)
        module:SetWidth(width)
        self.lastWidth = width
        self.dirty = true
    end

    if self.lastOffset ~= offset then
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, -offset)
        self.lastOffset = offset
    end

    if self.availableHeight ~= availableHeight then
        self.availableHeight = availableHeight
        self.dirty = true
    end

    if self.wasSupressed then
        self.wasSupressed = false
        self.dirty = true
    end

    if self.dirty then
        self.dirty = false

        local heightUsed = module:Update(availableHeight, false)
        self:SetHeight(math.max(1, heightUsed))
    end
end