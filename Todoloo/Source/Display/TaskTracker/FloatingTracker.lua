TODOLOO_DEFAULT_TRACKER_MODULE = {}

function TODOLOO_DEFAULT_TRACKER_MODULE:OnLoad(friendlyName, defaultTemplate)
    self.friendlyName = friendlyName or "UnnamedTodolooTrackerModule"
    self.groupTemplate = defaultTemplate or "TodolooTrackerGroupTemplate"
    self.groupType = "Frame"
    self.taskTemplate = "TodolooTrackerTaskTemplate"
    self.taskSpacing = 4
    self.taskWidth = TODOLOO_TRACKER_TEXT_WIDTH
    self.poolCollection = CreateFramePoolCollection()
    self.usedGroups = {}
    self.freeTasks = {}
    self.fromHeaderOffsetY = -10
    self.fromModuleOffsetY = -10
    self.contentsHeight = 0

    self.groupsFrame = TodolooFloatingTrackerFrame.GroupsFrame

    TODOLOO_DEFAULT_TRACKER_MODULE.AddGroupOffset(self, self.groupTemplate, 0, -10)
end

function TodolooTracker_GetModuleInfoTable(friendlyName, baseModule, defaultTemplate)
	local info = CreateFromMixins(baseModule or TODOLOO_DEFAULT_TRACKER_MODULE);
	info:OnLoad(friendlyName, defaultTemplate);
	return info;
end

function TODOLOO_DEFAULT_TRACKER_MODULE:BeginLayout()
    self.topGroup = nil
    self.firstGroup = nil
    self.lastGroup = nil
    self.contentsHeight = 0

    self.Header:Hide()
    self:MarkGroupsUnused()
end

function TODOLOO_DEFAULT_TRACKER_MODULE:EndLayout()
    self.lastGroup = self.groupsFrame.currentGroup
    self:FreeUnusedGroups()
end

function TODOLOO_DEFAULT_TRACKER_MODULE:SetHeader(group, text)
    group.module = self
    group.isHeader = true
    group.Text:SetText(text)
    self.Header = group
end

function TODOLOO_DEFAULT_TRACKER_MODULE:MarkGroupsUnused()
    for _, groupTable in pairs(self.usedGroups) do
        for _, group in pairs(groupTable) do
            group.used = nil
        end
    end
end

function TODOLOO_DEFAULT_TRACKER_MODULE:FreeUnusedGroups()
    for _, groupTable in pairs(self.usedGroups) do
        for _, group in pairs(groupTable) do
            if not group.used then
                self:FreeGroup(group)
            end
        end
    end
end

function TODOLOO_DEFAULT_TRACKER_MODULE:FreeGroup(group)
    -- free all tasks
    for _, task in pairs(group.tasks) do
        self:FreeTask(group, task)
    end

    group.tasks = {}

    -- free the group
    self.usedGroups[group.groupTemplate][group.id] = nil
    
    group.groupRef = nil
    group.isHighlighted = nil
    group.currentTask = nil

    self.poolCollection:Release(group)
end

function TODOLOO_DEFAULT_TRACKER_MODULE:FreeUnusedTasks(group)
    for _, task in pairs(group.tasks) do
        if not task.used then
            self:FreeTask(group, task)
        end
    end
end

function TODOLOO_DEFAULT_TRACKER_MODULE:ResetTaskVisuals(task)
    task.FadeOutAnim:Stop()
    task.CheckFlash.Anim:Stop()
    task.Glow.Anim:Stop()
    task.Sheen.Anim:Stop()

    task:SetAlpha(1)

    task.Check:Hide()
    task.Check:SetAlpha(1)
    task.CheckFlash:SetAlpha(0)
    task.Glow:SetAlpha(0)
    task.Sheen:SetAlpha(0)

    task.Dash:Show()
    task.Dash:SetText(QUEST_DASH)

    task.state = TODOLOO_TRACKER_TASK_STATE_PRESENT
    task.dashStyle = nil
    task.width = nil
    task.Text.colorStyle = nil

    task:ClearAllPoints()
end

function TODOLOO_DEFAULT_TRACKER_MODULE:FreeTask(group, task)
    if not task.id or group.tasks[task.id] ~= task then
        return
    end

    local freeTasks = task.type and task.type.freeTasks or self.freeTasks

    group.tasks[task.id] = nil

    task:Hide()
    
    Todoloo.Utils.HideTaskTooltip(task)
    task.isHighlighted = nil

    self:ResetTaskVisuals(task)

    task.id = nil
    task.group = nil
    task.module = nil
    task.taskRef = nil
    task.used = nil

    table.insert(freeTasks, task)
end

function TODOLOO_DEFAULT_TRACKER_MODULE:GetExistingGroup(id, overrideTemplate)
    local template = overrideTemplate or self.groupTemplate
    assert(template)
    assert(self.usedGroups)

    local groups = self.usedGroups[template]
    if groups then
        return groups[id]
    end

    return nil
end

function TODOLOO_DEFAULT_TRACKER_MODULE:GetGroup(id, overrideType, overrideTemplate)
    local groupType = overrideType or self.groupType
    local groupTemplate = overrideTemplate or self.groupTemplate

    if not self.usedGroups[groupTemplate] then
        self.usedGroups[groupTemplate] = {}
    end

    -- try to get existing group
    local group = self.usedGroups[groupTemplate][id]

    -- if no existing group exists, create it
    if not group then
        local pool = self.poolCollection:GetOrCreatePool(groupType, self.GroupsFrame or TodolooFloatingTrackerFrame.GroupsFrame, groupTemplate)

        local isNewGroup = nil
        group, isNewGroup = pool:Acquire(self.groupTemplate)

        if isNewGroup then
            group.groupTemplate = groupTemplate
            group.tasks = {}
        end

        self.usedGroups[groupTemplate][id] = group
        group.id = id
        group.module = self
    end

    group.used = true
    group:SetWidth(TodolooFloatingTrackerFrame:GetWidth())
    group.height = 0
    group.currentTask = nil

    if group.tasks then
        for _, task in pairs(group.tasks) do
            task.used = nil
        end
    end

    return group
end

function TODOLOO_DEFAULT_TRACKER_MODULE:GetTask(group, taskIndex, taskType)
    local task = group.tasks[taskIndex]

    if task and task.type ~= taskType then
        self:FreeTask(group, task)
        task = nil
    end

    if task then
        task.used = true
        return task
    end

    local freeTasks = taskType and taskType.freeTasks or self.freeTasks

    if #freeTasks > 0 then
        task = table.remove(freeTasks)
    else
        task = CreateFrame("Frame", nil, group, taskType and taskType.template or self.taskTemplate)
    end

    self:ResetTaskVisuals(task)
    task.isHighlighted = nil

    task:SetParent(group)
    task.type = taskType
    task.module = self
    task.group = group
    task.id = taskIndex
    task.used = true

    group.tasks[taskIndex] = task

    task:Show()

    return task
end

function TODOLOO_DEFAULT_TRACKER_MODULE:AddTask(group, taskIndex, text, taskType, useFullHeight, dashStyle, colorStyle)
    local task = self:GetTask(group, taskIndex, taskType)
    
    task:SetWidth(group:GetWidth())
    
    -- width
    local width = group.taskWidth or self.taskWidth
    if task.width ~= width then
        task.Text:SetWidth(width)
        task.width = width
    end

    -- dash
    if task.Dash then
        if not dashStyle then
            -- if dashStyle not provided, we default to show
            dashStyle = TODOLOO_TRACKER_DASH_STYLE_SHOW
        end
        if task.dashStyle ~= dashStyle then
            if dashStyle == TODOLOO_TRACKER_DASH_STYLE_SHOW then
                task.Dash:Show()
                task.Dash:SetText(QUEST_DASH)
            elseif dashStyle == TODOLOO_TRACKER_DASH_STYLE_HIDE then
                task.Dash:Hide()
                task.Dash:SetText(QUEST_DASH)
            elseif dashStyle == TODOLOO_TRACKER_DASH_STYLE_HIDE_AND_COLLAPSE then
                task.Dash:Hide()
                task.Dash:SetText(nil)
            end
            task.dashStyle = dashStyle
        end
    end

    -- set task text
    local textHeight = self:SetStringText(task.Text, text, useFullHeight, colorStyle, group.isHighlighted)
    task:SetHeight(textHeight)

    group.height = group.height + textHeight + self.taskSpacing

    local yOffset = -group.module.taskSpacing

    -- anchor the task
    local anchor = group.currentTask or group.HeaderText
    if anchor then
        task:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset)
    else
        task:SetPoint("TOPLEFT", 0, yOffset)
    end

    group.currentTask = task
    return task
end

function TODOLOO_DEFAULT_TRACKER_MODULE:UpdateTaskHighlight(task)
    if task.id == "GroupComplete" then
        return
    end

    local completed = task.taskRef and task.taskRef.completed
    local highlighted = task.isHighlighted
        or (task.group and task.group.isHighlighted)

    local colorStyle = TODOLOO_TRACKER_COLOR[
        completed and "Complete" or "Normal"
    ]

    if highlighted and colorStyle.reverse then
        colorStyle = colorStyle.reverse
    end

    task.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
    task.Text.colorStyle = colorStyle

    if task.Dash then
        local dashColor = TODOLOO_TRACKER_COLOR[
            highlighted and "NormalHighlight" or "Normal"
        ]

        task.Dash:SetTextColor(dashColor.r, dashColor.g, dashColor.b)
    end
end

function TODOLOO_DEFAULT_TRACKER_MODULE:OnTaskEnter(task)
    if task.id == "GroupComplete" then
        return
    end

    task.isHighlighted = true
    self:UpdateTaskHighlight(task)

    local taskInfo = Todoloo.Tasks.ResolveTrackerTask(
        task:GetParent().id,
        task.id,
        task.taskRef
    )

    Todoloo.Utils.ShowTaskTooltip(task, taskInfo)
end

function TODOLOO_DEFAULT_TRACKER_MODULE:OnTaskLeave(task)
    Todoloo.Utils.HideTaskTooltip(task)

    task.isHighlighted = nil
    self:UpdateTaskHighlight(task)
end

function TODOLOO_DEFAULT_TRACKER_MODULE:OnTaskClick(task, mouseButton)
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

    if task.id == "GroupComplete" then
        return
    end

    if task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETING then
        return
    end

    local groupId = task:GetParent().id

    if not Todoloo.Tasks.ResolveTrackerTask(groupId, task.id, task.taskRef) then
        TodolooTracker_Update()
        return
    end

    Todoloo.TaskManager:AdjustTaskProgress(groupId, task.id, amount)
end

function TODOLOO_DEFAULT_TRACKER_MODULE:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
    if useFullHeight then
        fontString:SetMaxLines(0)
    else
        fontString:SetMaxLines(2)
    end

    fontString:SetText(text)

    local stringHeight = fontString:GetHeight()
    colorStyle =  colorStyle or TODOLOO_TRACKER_COLOR["Normal"]
    if useHighlight and colorStyle.reverse then
        colorStyle = colorStyle.reverse
    end
    if fontString.colorStyle ~= colorStyle then
        fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
        fontString.colorStyle = colorStyle
    end

    return stringHeight
end

function TODOLOO_DEFAULT_TRACKER_MODULE:IsCollapsed()
    return self.collapsed
end

local function GetGroupTemplate(group)
    return group.groupTemplate or group.module.groupTemplate
end

function TodolooTracker_GetGroupOffset(group)
    local offset = group.module.groupOffset
    if offset then
        return unpack(offset[GetGroupTemplate(group)])
    end

    return 0, 0
end

local function AnchorGroup(group, anchorGroup, checkFit)
    local module = group.module
    local groupsFrame = module.groupsFrame
    local offsetX, offsetY = TodolooTracker_GetGroupOffset(group)
    group:ClearAllPoints()

    if anchorGroup then
        if anchorGroup.isHeader then
            offsetY = module.fromHeaderOffsetY
        end

        -- check if there's room for the group. If not, end execution
        if checkFit and (groupsFrame.contentsHeight + group.height - offsetY > groupsFrame.maxHeight) then
            return
        end

        if group.isHeader then
            offsetY = offsetY + anchorGroup.module.fromModuleOffsetY
            group:SetPoint("LEFT", TODOLOO_TRACKER_HEADER_OFFSET_X, 0)
        else
            group:SetPoint("LEFT", offsetX, 0)
        end

        group:SetPoint("TOP", anchorGroup, "BOTTOM", 0, offsetY)
    else 
        offsetY = 0
        -- check if there's room for the group. If not, end execution
        if checkFit and (groupsFrame.contentsHeight + group.height > groupsFrame.maxHeight) then
            return
        end
        if group.isHeader then
            group:SetPoint("TOPLEFT", groupsFrame, "TOPLEFT", TODOLOO_TRACKER_HEADER_OFFSET_X, offsetY)
        else
            group:SetPoint("TOPLEFT", groupsFrame, "TOPLEFT", offsetX, offsetY)
        end
    end

    return offsetY
end

local function InternalAddGroup(group)
    local module = group.module or TODOLOO_DEFAULT_TRACKER_MODULE
    local groupsFrame = module.groupsFrame
    group.nextGroup = nil

    if not group.isHeader and module:IsCollapsed() then
        return false
    end

    local offsetY = AnchorGroup(group, groupsFrame.currentGroup, not module.ignoreFit)
    if not offsetY then
        return false
    end

    if not module.topGroup then
        module.topGroup = group
    end
    if not module.firstGroup and not group.isHeader then
        module.firstGroup = group
    end
    if module.groupsFrame.currentGroup then
        module.groupsFrame.currentGroup.nextGroup = group
    end
    module.groupsFrame.currentGroup = group
    module.groupsFrame.contentsHeight = module.groupsFrame.contentsHeight + group.height - offsetY
    module.contentsHeight = module.contentsHeight + group.height - offsetY

    return true
end

function TodolooTracker_AddHeader(header)
    if InternalAddGroup(header) then
        header.added = true
        header:Show()
        return true
    end

    return false
end

function TodolooTracker_AddGroup(group)
    local header = group.module.Header
    local groupAdded = false

    if not header or header.added then
        groupAdded = InternalAddGroup(group)
    elseif TodolooTracker_CanFitGroup(group, header) then
        if TodolooTracker_AddHeader(header) then
            groupAdded = InternalAddGroup(group)
        end
    end

    return groupAdded
end

function TodolooTracker_CanFitGroup(group, header)
    local module = group.module
    local groupsFrame = module.groupsFrame
    local offsetY

    if not groupsFrame.currentGroup then
        offsetY = 0
    elseif groupsFrame.currentGroup.isHeader then
        offsetY = module.fromHeaderOffsetY
    else
        offsetY = select(2, TodolooTracker_GetGroupOffset(group))
    end

    local totalHeight
    if header then
        totalHeight = header.height - offsetY + group.height - module.fromHeaderOffsetY
    else
        totalHeight = group.height - offsetY
    end

    return (groupsFrame.contentsHeight + totalHeight) <= groupsFrame.maxHeight
end

local function TodolooTracker_AddCustomizationData(module, customizationKey, template, data)
    if not module[customizationKey] then
        module[customizationKey] = {}
    end

    module[customizationKey][template] = data
end

function TODOLOO_DEFAULT_TRACKER_MODULE:AddGroupOffset(template, x, y)
    TodolooTracker_AddCustomizationData(self, "groupOffset", template, { x or 0, y or 0 })
end

function TodolooTracker_OnLoad(self)
    TODOLOO_DEFAULT_TRACKER_MODULE.OnLoad(self, "TODOLOO_DEFAULT_TRACKER_MODULE")

    self:RegisterForDrag("LeftButton")

    -- get measurements
    local task = CreateFrame("Frame", nil, self, self.taskTemplate)
    task.Text:SetText("Double line|ntest")
    tinsert(self.freeTasks, task)
    TODOLOO_TRACKER_DASH_WIDTH = task.Dash:GetWidth()
    TODOLOO_TRACKER_TEXT_WIDTH = TODOLOO_TRACKER_TASK_WIDTH - TODOLOO_TRACKER_DASH_WIDTH - 12
    task.Text:SetWidth(TODOLOO_TRACKER_TEXT_WIDTH)

    -- set header menu frame level
    local frameLevel = self.GroupsFrame:GetFrameLevel()
    self.HeaderMenu:SetFrameLevel(frameLevel + 2)

    -- register for event to start up
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    self.trackerEvents = {
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
    }
end

function TodolooTracker_OnShow(self)
    if not self.eventsRegistered then
        Todoloo.EventBus:RegisterEvents(self, self.trackerEvents, TodolooTracker_ReceiveEvent)

        self.eventsRegistered = true
    end

    if self.initialized then
        TodolooTracker_Update()
    end
end

function TodolooTracker_OnHide(self)
    if self.eventsRegistered then
        Todoloo.EventBus:UnregisterEvents(self, self.trackerEvents)
        self.eventsRegistered = false
    end
end

function TodolooTracker_Initialize(self)
    self.MODULES = { TODOLOO_TASK_TRACKER_MODULE }

    self.initialized = true

    -- set width and height based on Todoloo config
    self:SetWidth(Todoloo.Config.Get(Todoloo.Config.Options.TASK_TRACKER_WIDTH))
    self:SetHeight(Todoloo.Config.Get(Todoloo.Config.Options.TASK_TRACKER_HEIGHT))

    TodolooTracker_UpdateBackground()
end

function TodolooTracker_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if not self.initialized then
            TodolooTracker_Initialize(self)
        end

        TodolooTracker_Update()
    elseif event == "PLAYER_REGEN_ENABLED" then
        if Todoloo.Config.Get(Todoloo.Config.Options.HIDE_TASK_TRACKER_IN_COMBAT) then
            if not self:IsVisible() and Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) and not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
                self:Show();
            end 
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if Todoloo.Config.Get(Todoloo.Config.Options.HIDE_TASK_TRACKER_IN_COMBAT) then
            if self:IsVisible() then
                self:Hide();
            end
        end
    end
end

function TodolooTracker_ReceiveEvent(self, event, ...)
    TodolooTracker_Update()
end

function TodolooTracker_OnSizeChanged(self)
    if self.isUpdating then
        return
    end

    TodolooTracker_Update()
end

function TodolooTracker_OnUpdate(self)
    if not self.initialized
        or not self:IsVisible()
        or not self.isUpdateDirty then
        return
    end

    TodolooTracker_Refresh()
end

function TodolooTracker_UpdateBackground()
    TodolooFloatingTrackerFrame.NineSlice:Hide()
end

function TodolooTracker_Refresh()
    local tracker = TodolooFloatingTrackerFrame

    if tracker.isUpdating then
        tracker.isUpdateDirty = true
        return
    end
    tracker.isUpdating = true

    if not tracker.initialized then
        tracker.isUpdating = false
        return
    end

    local trackerWidth = math.max(1, tonumber(Todoloo.Config.Get(Todoloo.Config.Options.TASK_TRACKER_WIDTH)) or 235)

    tracker:SetWidth(trackerWidth)

    TODOLOO_TRACKER_TEXT_WIDTH = math.max(1, trackerWidth - TODOLOO_TRACKER_DASH_WIDTH - 12)

    tracker.GroupsFrame.maxHeight = math.max(
        1,
        tonumber(Todoloo.Config.Get(
            Todoloo.Config.Options.TASK_TRACKER_HEIGHT
        )) or TODOLOO_TRACKER_MAX_HEIGHT
    )

    tracker.isUpdateDirty = false

    tracker.GroupsFrame.currentGroup = nil
    tracker.GroupsFrame.contentsHeight = 0

    for _, module in ipairs(tracker.MODULES) do
        if module.Header then
            module.Header.added = nil
        end
    end

    for _, module in ipairs(tracker.MODULES) do
        if module.Header then
            module.Header.enabled = nil
        end
    end

    for _, module in ipairs(tracker.MODULES) do
        module.taskWidth = TODOLOO_TRACKER_TEXT_WIDTH

        if module.Header then
            local headerWidth = trackerWidth - TODOLOO_TRACKER_HEADER_OFFSET_X

            module.Header:SetWidth(headerWidth)
            module.Header.Background:SetWidth(headerWidth)
            module.Header.Text:SetWidth(math.max(1, headerWidth - 14))
        end

        module:Update()
    end

    if tracker.GroupsFrame.currentGroup then
        tracker.HeaderMenu:Show()
    else
        tracker.HeaderMenu:Hide()
    end

    TodolooTracker_UpdateBackground()

    tracker.currentGroup = nil
    tracker:SetHeight(math.max(1, tracker.GroupsFrame.contentsHeight))
    tracker.isUpdating = false
end

function TodolooTracker_Update()
    TodolooFloatingTrackerFrame.isUpdateDirty = true
end

function TodolooTracker_OnDragStart(self)
    self:StartMoving()
end

function TodolooTracker_OnDragStop(self)
    self:StopMovingOrSizing()
end

function TodolooTrackerTask_OnLoad(self)
    self:RegisterForClicks("LeftButtonUp", "RightButtonDown")
end

function TodolooTrackerTask_OnClick(self, mouseButton)
    local task = self:GetParent()
    task.module:OnTaskClick(task, mouseButton)
end

function TodolooTrackerTask_OnEnter(self)
    local task = self:GetParent()
    task.module:OnTaskEnter(task)
end

function TodolooTrackerTask_OnLeave(self)
    local task = self:GetParent()
    task.module:OnTaskLeave(task)
end

function TaskTracker_FinishGlowAnim(task)
    local group = task.group

    if not group or group.tasks[task.id] ~= task then
        return
    end

    if task.state == TODOLOO_TRACKER_TASK_STATE_ADDING then
        task.state = TODOLOO_TRACKER_TASK_STATE_PRESENT
        return
    end

    if task.state ~= TODOLOO_TRACKER_TASK_STATE_COMPLETING then
        return
    end

    local taskInfo = Todoloo.Tasks.ResolveTrackerTask(group.id, task.id, task.taskRef)

    if not taskInfo or not taskInfo.completed then
        TodolooTracker_Update()
        return
    end

    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS)  then
        task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETED
    else
        task.state = TODOLOO_TRACKER_TASK_STATE_FADING
        task.FadeOutAnim:Play()
    end
end

function TaskTracker_FinishFadeOutAnim(task)
    local group = task.group

    if not group or group.tasks[task.id] ~= task then
        return
    end

    if task.state ~= TODOLOO_TRACKER_TASK_STATE_FADING then
        return
    end

    group.module:FreeTask(group, task)

    for _, otherTask in pairs(group.tasks) do
        if otherTask.state == TODOLOO_TRACKER_TASK_STATE_FADING then
            return
        end
    end

    TodolooTracker_Update()
end

TodolooTrackerHeaderMixin = {}

function TodolooTrackerHeaderMixin:OnLoad()
    self.height = TODOLOO_TRACKER_HEADER_HEIGHT
end

TodolooTrackerTaskMixin = {}

function TodolooTrackerTaskMixin:OnLoad()
    self.Text:SetWidth(TODOLOO_TRACKER_TEXT_WIDTH)
end