-- *****************************************************************************************************
-- ***** MODULE
-- *****************************************************************************************************
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
    self.contentsAnimHeight = 0
    self.oldContentsHeight = 0
    self.hasSkippedGroups = false
    self.userProgressBars = {}
    self.freeProgressBars = {}
    self.updateReasonModule = 0
    self.updateReasonEvents = 0

    self.groupsFrame = TodolooFloatingTrackerFrame.GroupsFrame

    TODOLOO_DEFAULT_TRACKER_MODULE.AddGroupOffset(self, self.groupTemplate, 0, -10)
end

---Build custom module info
---@param friendlyName string Friendly name of the module
---@param baseModule table Base module to derive from
---@param defaultTemplate string Default template to use for group frames
---@return table info Module info
function TodolooTracker_GetModuleInfoTable(friendlyName, baseModule, defaultTemplate)
	local info = CreateFromMixins(baseModule or TODOLOO_DEFAULT_TRACKER_MODULE);
	info:OnLoad(friendlyName, defaultTemplate);
	return info;
end

---Begin building new layout
---@param staticReanchor boolean|nil
function TODOLOO_DEFAULT_TRACKER_MODULE:BeginLayout(staticReanchor)
    self.topGroup = nil
    self.firstGroup = nil
    self.lastGroup = nil
    self.oldContentsHeight = self.contentsHeight
    self.contentsHeight = 0
    self.contentsAnimHeight = 0
    self.potentialGroupsAddedThisLayout = 0
    if not staticReanchor then
        self.hasSkippedGroup = false
        self.Header:Hide()
    end

    self:MarkGroupsUnused()
end

---End build new layout
---@param isStaticReanchor boolean|nil
function TODOLOO_DEFAULT_TRACKER_MODULE:EndLayout(isStaticReanchor)
    self.lastGroup = self.groupsFrame.currentGroup
    self:FreeUnusedGroups()
end

---Set the header of the module
---@param group Frame Header frame
---@param text string String value to display in the header
---@param animateReason any
function TODOLOO_DEFAULT_TRACKER_MODULE:SetHeader(group, text, animateReason)
    group.module = self
    group.isHeader = true
    group.Text:SetText(text)
    group.animateReason = animateReason or 0
    self.Header = group
end

---Mark all groups as unused
function TODOLOO_DEFAULT_TRACKER_MODULE:MarkGroupsUnused()
    for _, groupTable in pairs(self.usedGroups) do
        for _, group in pairs(groupTable) do
            group.used = nil
        end
    end
end

---Free up all unused groups and nested tasks
function TODOLOO_DEFAULT_TRACKER_MODULE:FreeUnusedGroups()
    for _, groupTable in pairs(self.usedGroups) do
        for _, group in pairs(groupTable) do
            if not group.used then
                self:FreeGroup(group)
            end
        end
    end
end

---Free up the group and all nested tasks
---@param group Frame
function TODOLOO_DEFAULT_TRACKER_MODULE:FreeGroup(group)
    -- free all tasks
    for _, task in pairs(group.tasks) do
        self:FreeTask(group, task)
    end

    group.tasks = {}

    -- free the group
    self.usedGroups[group.groupTemplate][group.id] = nil
    self.poolCollection:Release(group)
end

---Free up all unused tasks
---@param group Frame Group frame
function TODOLOO_DEFAULT_TRACKER_MODULE:FreeUnusedTasks(group)
    for _, task in pairs(group.tasks) do
        if not task.used then
            self:FreeTask(group, task)
        end
    end
end

---TODO: Add documentation
---@param group any
---@param task any
function TODOLOO_DEFAULT_TRACKER_MODULE:FreeTask(group, task)
    group.tasks[task.id] = nil
    local freeTasks = task.type and task.type.freeTasks or self.freeTasks
    tinsert(freeTasks, task)

    task:Hide()
end

---Get existing group frame
---@param id integer Group ID
---@param overrideTemplate any
---@return unknown
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

---Get or create group
---@param id integer Group ID
---@param overrideType any
---@param overrideTemplate any
---@return Frame
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
    group.height = 0
    group.currentTask = nil

    if group.tasks then
        for _, task in pairs(group.tasks) do
            task.used = nil
        end
    end

    return group
end

---TODO: Add documentation
---@param group Frame
---@param taskIndex integer
---@param taskType any --TODO: Add documentation
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
    local numFreeTasks = #freeTasks
    if numFreeTasks > 0 then
        -- get a free task
        task = freeTasks[numFreeTasks]
        tremove(freeTasks, numFreeTasks)
        task:SetParent(group)
        task:Show()
    else
        -- create new task
        task = CreateFrame("Frame", nil, group, taskType and taskType.template or self.taskTemplate)
        task.type = taskType
        task.module = self
    end

    group.tasks[taskIndex] = task
    task.id = taskIndex
    task.used = true

    return task
end

---Add new task frame
---@param group Frame Group the task should be added to
---@param taskIndex integer|string The index of the task or string if not relevant
---@param text string Name/title of the task
---@param taskType any --TODO: Add documentation
---@param useFullHeight boolean Whether or not to use full height
---@param dashStyle integer The dash style to use fo the task
---@param colorStyle table|nil The color style to use for the task
function TODOLOO_DEFAULT_TRACKER_MODULE:AddTask(group, taskIndex, text, taskType, useFullHeight, dashStyle, colorStyle)
    local task = self:GetTask(group, taskIndex, taskType)
    
    -- width
    if group.taskWidth ~= task.width then
        task.Text:SetWidth(group.taskWidth or self.taskWidth)
        task.width = group.taskWidth
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

---Set color style on the group and underlying tasks on mouse hover
---@param group Frame
function TODOLOO_DEFAULT_TRACKER_MODULE:OnGroupHeaderEnter(group)
    group.isHighlighted = true
    if group.HeaderText then
        local headerColorStyle = TODOLOO_TRACKER_COLOR["HeaderHighlight"]
        group.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b)
        group.HeaderText.colorStyle = headerColorStyle
    end

    for _, task in pairs(group.tasks) do
        -- if we're currently showing group complete, do nothing on click
        if task.id == "GroupComplete" then
            return
        end

        task.isHighligthed = true
        local colorStyle = task.Text.colorStyle.reverse
        if colorStyle then
            task.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
            task.Text.colorStyle = colorStyle
            if task.Dash then
                task.Dash:SetTextColor(TODOLOO_TRACKER_COLOR["NormalHighlight"].r, TODOLOO_TRACKER_COLOR["NormalHighlight"].g, TODOLOO_TRACKER_COLOR["NormalHighlight"].b)
            end
        end
    end
end

---Set color style on the group and underlying tasks on mouse leave
---@param group Frame
function TODOLOO_DEFAULT_TRACKER_MODULE:OnGroupHeaderLeave(group)
    group.isHighlighted = nil
    if group.HeaderText then
        local headerColorStyle = TODOLOO_TRACKER_COLOR["Header"]
        group.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b)
        group.HeaderText.colorStyle = headerColorStyle
    end

    for _, task in pairs(group.tasks) do
        -- if we're currently showing group complete, do nothing on click
        if task.id == "GroupComplete" then
            return
        end
        
        task.isHighligthed = nil
        local colorStyle = task.Text.colorStyle.reverse
        if colorStyle then
            task.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
            task.Text.colorStyle = colorStyle
            if task.Dash then
                task.Dash:SetTextColor(TODOLOO_TRACKER_COLOR["Normal"].r, TODOLOO_TRACKER_COLOR["Normal"].g, TODOLOO_TRACKER_COLOR["Normal"].b)
            end
        end
    end
end

---Set color style on the task on mouse hover
---@param task Frame
function TODOLOO_DEFAULT_TRACKER_MODULE:OnTaskEnter(task)
    -- if we're currently showing group complete, do nothing
    if task.id == "GroupComplete" then
        return
    end

    task.isHighlighted = true
    if task.Text then
        if task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETED or task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETING then
            local textColorStyle = TODOLOO_TRACKER_COLOR["CompleteHighlight"]
            task.Text:SetTextColor(textColorStyle.r, textColorStyle.g, textColorStyle.b)
        else
            local textColorStyle = TODOLOO_TRACKER_COLOR["NormalHighlight"]
            task.Text:SetTextColor(textColorStyle.r, textColorStyle.g, textColorStyle.b)
        end
    end
end

---Set color style on the task on mouse leave
---@param task Frame
function TODOLOO_DEFAULT_TRACKER_MODULE:OnTaskLeave(task)
    -- if we're currently showing group complete, do nothing on click
    if task.id == "GroupComplete" then
        return
    end

    task.isHighlighted = nil
    if task.Text then
        if task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETED or task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETING then
            local textColorStyle = TODOLOO_TRACKER_COLOR["Complete"]
            task.Text:SetTextColor(textColorStyle.r, textColorStyle.g, textColorStyle.b)
        else
            local textColorStyle = TODOLOO_TRACKER_COLOR["Normal"]
            task.Text:SetTextColor(textColorStyle.r, textColorStyle.g, textColorStyle.b)
        end
    end
end

---Mark the task as completed
---@param task Frame
---@param mouseButton string
function TODOLOO_DEFAULT_TRACKER_MODULE:OnTaskClick(task, mouseButton)
    if IsShiftKeyDown() then
        -- if we're currently showing group complete, do nothing
        if task.id == "GroupComplete" then
            return
        end

        -- we have to wait for it to finish completing
        if task.state and task.state == TODOLOO_TRACKER_TASK_STATE_COMPLETING then
            return
        end

        -- complete the task
        local group = task:GetParent()
        local groupId = group.id
        local id = task.id

        local taskInfo = Todoloo.TaskManager:GetTask(groupId, id)
        Todoloo.TaskManager:SetTaskCompletion(groupId, id, not taskInfo.completed)
    end
end

---Set text and style on the given font string element
---@param fontString FontString Font string element
---@param text string Value to display
---@param useFullHeight boolean Whether or not to use full height
---@param colorStyle table|nil The color style to use for the font string
---@param useHighlight boolean Whether or not to highlight the text
---@return integer height The resulting height of the font string element
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

function GetGroupTemplate(group)
    return group.groupTemplate or group.module.groupTemplate
end

function TodolooTracker_GetGroupOffset(group)
    local offset = group.module.groupOffset
    if offset then
        return unpack(offset[GetGroupTemplate(group)])
    end

    return 0, 0
end

---@param group any
---@param anchorGroup any
---@param checkFit any
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

    if not group.isHeader then
        module.potentialGroupsAddedThisLayout = (module.potentialGroupsAddedThisLayout or 0) + 1
    end

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
    module.contentsAnimHeight = module.contentsHeight + group.height
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

    -- if there's not room for the group, mark on the module that we have skipped some groups
    if not groupAdded then
        group.module.hasSkippedGroup = true
    end

    return groupAdded
end

---Check if this group can fit into the tracker frame
---@param group Frame
---@param header Frame
---@return boolean canFit True if there's room, otherwise false
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

    return (groupsFrame.contentsHeight + totalHeight) <= TODOLOO_TRACKER_MAX_HEIGHT
end

-- *****************************************************************************************************
-- ***** MODULE CUSTOMIZATION
-- *****************************************************************************************************

---Add customization data to the given module
---@param module any
---@param customizationKey any
---@param template any
---@param data any
local function TodolooTracker_AddCustomizationData(module, customizationKey, template, data)
    if not module[customizationKey] then
        module[customizationKey] = {}
    end

    module[customizationKey][template] = data
end

function TODOLOO_DEFAULT_TRACKER_MODULE:AddGroupOffset(template, x, y)
    TodolooTracker_AddCustomizationData(self, "groupOffset", template, { x or 0, y or 0 })
end

-- *****************************************************************************************************
-- ***** FRAME HANDLERS
-- *****************************************************************************************************

---On main frame load
---@param self Frame Main frame
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
end

function TodolooTracker_OnShow(self)
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
    }, TodolooTracker_ReceiveEvent)
    
    --TODO: Set max height based on Todoloo config
    --TodolooTracker_UpdateHeight()
end

function TodolooTracker_Initialize(self)
    self.MODULES = { TODOLOO_TASK_TRACKER_MODULE }
    self.MODULES_UI_ORDER = { TODOLOO_TASK_TRACKER_MODULE }

    self.initialized = true

    -- set width and height based on Todoloo config
    self:SetWidth(Todoloo.Config.Get(Todoloo.Config.Options.TASK_TRACKER_WIDTH))
    self:SetHeight(Todoloo.Config.Get(Todoloo.Config.Options.TASK_TRACKER_HEIGHT))

    TodolooTracker_UpdateResizeButton()
    TodolooTracker_UpdateBackground()
end

---Event handling
---@param self Frame Main frame
---@param event string Event type
---@param ... unknown
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

---Event handling (custom Todoloo events)
function TodolooTracker_ReceiveEvent(event, ...)
    TodolooTracker_Update();
end

function TodolooTracker_OnSizeChanged(self)
    TodolooTracker_Update()
end

function TodolooTracker_OnUpdate(self)
    if self.isUpdateDirty then
        TodolooTracker_Update()
    end
end

---Set the opacity of the background based on Todoloo config
--TODO: Awaiting implementation
function TodolooTracker_UpdateOpacity()
    local self = TodolooFloatingTrackerFrame
    local alpha = Todoloo.Config.Get(Todoloo.Config.Options.TASK_TRACKER_BACKGROUND_OPACITY) / 100
    self.NineSlice:SetAlpha(alpha)
end

---Update the background
--TODO: Awaiting implementation
function TodolooTracker_UpdateBackground()
    TodolooFloatingTrackerFrame.NineSlice:Hide()
    --TODO: Implement

    -- if lastGroup and not TodolooFloatingTrackerFrame.collapsed then
    --     TodolooFloatingTrackerFrame.NineSlice:Show()
    --     TodolooFloatingTrackerFrame.NineSlice:SetPoint("BOTTOM", lastGroup, "BOTTOM", 0, -10)
    -- else
    --     TodolooFloatingTrackerFrame.NineSlice:Hide()
    -- end
end

--TODO: Add resizing logic
function TodolooTracker_UpdateResizeButton()
    -- local tracker = TodolooFloatingTrackerFrame

    -- if tracker.resizing then
    --     return;
    -- end

    -- local lastGroup
    -- if tracker.initialized then
    --     for _, module in ipairs_reverse(tracker.MODULES_UI_ORDER) do
    --         if module.topGroup then
    --             lastGroup = module.lastGroup
    --         end
    --     end
    -- end


    -- if lastGroup and not TodolooFloatingTrackerFrame.collapsed then
    --     TodolooFloatingTrackerFrame.ResizeButton:Show()
    --     TodolooFloatingTrackerFrame.ResizeButton:SetPoint("BOTTOMRIGHT", lastGroup, "BOTTOMRIGHT", 0, -10)
    -- else
    --     TodolooFloatingTrackerFrame.ResizeButton:Hide()
    -- end
end

---Get currently visible headers across all modules
function TodolooTracker_GetVisibleHeaders()
    local headers = {}
    for _, module in ipairs(TodolooFloatingTrackerFrame.MODULES) do
        local header = module.Header
        if header.added and header:IsVisible() then
            headers[header] = true
        end
    end

    return headers
end

function TodolooTracker_Update(reason, id, subInfo)
    local tracker = TodolooFloatingTrackerFrame

    if not reason then
        --TODO: See line 1404 in Blizzard_ObjectiveTracker.lua. Is this necessary?
    end

    -- we're already updating, try again next frame
    if tracker.isUpdating then
        tracker.isUpdateDirty = true
        return
    end
    tracker.isUpdating = true

    -- we can't update before we've initialized
    if not tracker.initialized then
        tracker.isUpdating = false
        return
    end

    tracker.GroupsFrame.maxHeight = TODOLOO_TRACKER_MAX_HEIGHT
    if tracker.GroupsFrame.maxHeight == 0 then
        tracker.isUpdating = false
        return
    end

    tracker.isUpdateDirty = false

    tracker.GroupsFrame.currentGroup = nil
    tracker.GroupsFrame.contentsHeight = 0

    -- headers
    local currentHeaders = TodolooTracker_GetVisibleHeaders()

    -- mark headers unused
    for _, module in ipairs(tracker.MODULES) do
        if module.Header then
            module.Header.added = nil
        end
    end

    -- run update
    for _, module in ipairs(tracker.MODULES) do
        if module.Header then
            module.Header.enabled = nil
        end
    end

    for i = 1, #tracker.MODULES do
        local module = tracker.MODULES[i]
        module:Update()
    end
    
    if tracker.GroupsFrame.currentGroup then
        tracker.HeaderMenu:Show()
    else
        tracker.HeaderMenu:Hide()
    end

    TodolooTracker_UpdateResizeButton()
    TodolooTracker_UpdateBackground()
    
    tracker.currentGroup = nil
    tracker.isUpdating = false
    tracker:SetHeight(tracker.GroupsFrame.contentsHeight)
end

---On main frame being moving
---@param self Frame Main frame
function TodolooTracker_OnDragStart(self)
    self:StartMoving()
end

---On main frame stop moving
---@param self Frame Main frame
function TodolooTracker_OnDragStop(self)
    self:StopMovingOrSizing()
end

--TODO: Add resizing logic
function TodolooTracker_ResizeButton_OnMouseDown(self)
    local tracker = self:GetParent()
    tracker.resizing = true
    tracker:StartSizing("BOTTOMRIGHT")
    tracker:SetUserPlaced(true)
end

--TODO: Add resizing logic
function TodolooTracker_ResizeButton_OnMouseup(self)
    local tracker = self:GetParent()
    tracker.resizing = nil
    tracker:StopMovingOrSizing()
    TodolooTracker_Update()
end

-- *****************************************************************************************************
-- ***** TASK HANDLERS
-- *****************************************************************************************************

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

-- *****************************************************************************************************
-- ***** ANIMATIONS
-- *****************************************************************************************************

---TODO: Add documentation
---@param task any
function TaskTracker_FinishGlowAnim(task)
    if task.state == TODOLOO_TRACKER_TASK_STATE_ADDING then
        task.state = TODOLOO_TRACKER_TASK_STATE_PRESENT
    elseif not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        task.FadeOutAnim:Play()
        task.state = TODOLOO_TRACKER_TASK_STATE_FADING
    else
        task.state = TODOLOO_TRACKER_TASK_STATE_COMPLETED
    end
end

---TODO: Add documentation
---@param task any
function TaskTracker_FinishFadeOutAnim(task)
    local group = task.group
    
    -- only free the task if we wish to remove the task from the tracker
    if not Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
        group.module:FreeTask(group, task)
    end

    for _, otherTask in pairs(group.tasks) do
        -- if other tasks are fading, we want to wait with the update until all tasks are done fading
        if otherTask.state == TODOLOO_TRACKER_TASK_STATE_FADING then
            return
        end
    end

    --TODO: Add reason
    TodolooTracker_Update()
end

-- *****************************************************************************************************
-- ***** PROGRESS BARS
-- *****************************************************************************************************
--TODO: Implement as Todoloo setting: "Show group task bars?"

---TODO: Add documentation
---@param self any
---@param percent any
function TodolooTrackerProgressBar_SetValue(self, percent)
    self.Bar:SetValue(percent)
    self.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent)
end

---TODO: Add documentation
---@param self any
---@param percent any
function TodolooTrackerProgressBar_OnEvent(self, percent)
    TodolooTrackerProgressBar_SetValue(self, TodolooTracker_GetGroupProgressBarPercent(self.groupIndex))
end

---Get percentage left on group based on tasks
---@param groupIndex integer Index of the group
---@return integer percentage Percentage left in a value between 0 and 100
function TodolooTracker_GetGroupProgressBarPercent(groupIndex)
    --TODO: Implement - See line 771 in Blizzard_ObjectiveTracker.lua
    return 47
end

-- *****************************************************************************************************
-- ***** BUTTONS
-- *****************************************************************************************************
TodolooTrackerMinimizeButtonMixin = {}

function TodolooTrackerMinimizeButtonMixin:OnLoad()
    local collapsed = false
    self:SetAtlases(collapsed)
end

---Set textures (atlases) based on whether or not the module is collapsed
---@param collapsed boolean Is the module collapsed?
function TodolooTrackerMinimizeButtonMixin:SetAtlases(collapsed)
    local normalTexture = self:GetNormalTexture()
    local pushedTexture = self:GetPushedTexture()

    if self.buttonType == "module" then
		if collapsed then
			normalTexture:SetAtlas("UI-QuestTrackerButton-Expand-Section", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Expand-Section-Pressed", true);
		else
			normalTexture:SetAtlas("UI-QuestTrackerButton-Collapse-Section", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Collapse-Section-Pressed", true);
		end
	else
		if collapsed then
			normalTexture:SetAtlas("UI-QuestTrackerButton-Expand-All", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Expand-All-Pressed", true);
		else
			normalTexture:SetAtlas("UI-QuestTrackerButton-Collapse-All", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Collapse-All-Pressed", true);
		end
	end
end

---Collaps or open this module
---@param collapsed boolean Should the module collapse?
function TodolooTrackerMinimizeButtonMixin:SetCollapsed(collapsed)
    self:SetAtlases(collapsed)
end

function TodolooTracker_MinimizeButton_OnClick()
    --TODO: Implement - See line 1077 in Blizzard_ObjectiveTracker.lua
end

function TodolooTracker_MinimizeModuleButton_OnClick(self)
    --TODO: Implement - See line 1087 in Blizzard_ObjectiveTracker.lua
end

-- *****************************************************************************************************
-- ***** TRACKER HEADER MIXIN
-- *****************************************************************************************************
TodolooTrackerHeaderMixin = {}

function TodolooTrackerHeaderMixin:OnLoad()
    self.height = TODOLOO_TRACKER_HEADER_HEIGHT
end

-- *****************************************************************************************************
-- ***** TASK MIXIN
-- *****************************************************************************************************
TodolooTrackerTaskMixin = {}

function TodolooTrackerTaskMixin:OnLoad()
    self.Text:SetWidth(TODOLOO_TRACKER_TEXT_WIDTH)
end