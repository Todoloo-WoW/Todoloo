TODOLOO_TASK_MANAGEMENT_GROUP_HEIGHT = 33

-- *****************************************************************************************************
-- ***** TASK MANAGEMENT
-- *****************************************************************************************************

function TodolooTaskManagement_BeginLayout(self)
    self.firstTask = nil
    self.oldContentsHeight = self.contentsHeight
    TodolooTaskManagement_MarkGroupsUnused(self)
    self.newTaskButtonPool:ReleaseAll()
end

function TodolooTaskManagement_EndLayout(self)
    self.lastGroup = self.groupsFrame.currentGroup
    TodolooTaskManagement_FreeUnusedGroups(self)
end

-- ***** GROUPS

function TodolooTaskManagement_MarkGroupsUnused(self)
    for _, group in pairs(self.usedGroups) do
        group.used = nil
    end
end

function TodolooTaskManagement_FreeUnusedGroups(self)
    for _, group in pairs(self.usedGroups) do
        if not group.used then
            TodolooTaskManagement_FreeGroup(self, group)
        end
    end
end

function TodolooTaskManagement_FreeGroup(self, group)
    -- free all tasks
    for _, task in pairs(group.tasks) do
        TodolooTaskManagement_FreeTask(self, group, task)
    end

    group.tasks = {}

    -- free the group
    self.usedGroups[group.id] = nil
    self.poolCollection:Release(group)
end

function TodolooTaskManagement_GetGroup(self, id)
    local group = self.usedGroups[id]

    -- if group doesn't already exist
    if not group then
        local pool = self.poolCollection:GetOrCreatePool("FRAME", self.groupsFrame, self.groupTemplate)

        local isNewGroup = nil
        group, isNewGroup = pool:Acquire(self.groupTemplate)

        if isNewGroup then
            group.tasks = {}
        end

        self.usedGroups[id] = group
        group.id = id
    end

    group.used = true
    group.currentTask = nil
    group.height = TODOLOO_TASK_MANAGEMENT_GROUP_HEIGHT + self.groupSpacing

    if group.tasks then
        for _, task in pairs(group.tasks) do
            task.used = nil
        end
    end

    return group
end

function TodolooTaskManagement_AddGroup(self, group)
    -- anchor the group
    group.nextGroup = nil
    local anchorGroup = self.groupsFrame.currentGroup
    group:ClearAllPoints()

    local offsetY = -self.groupSpacing

    if anchorGroup then
        group:SetPoint("TOP", anchorGroup, "BOTTOM", 0, offsetY)
    else
        group:SetPoint("TOPLEFT", self.groupsFrame)
    end

    if not self.topGroup then
        self.topGroup = group
    end
    if not self.firstGroup then
        self.firstGroup = group
    end
    if self.groupsFrame.currentGroup then
        self.groupsFrame.currentGroup.nextGroup = group
    end

    self.groupsFrame.currentGroup = group
    self.groupsFrame.contentsHeight = self.groupsFrame.contentsHeight + group.height
    self.contentsHeight = self.contentsHeight + group.height
end

-- ***** TASKS

function TodolooTaskManagement_FreeUnusedTasks(self, group)
    for _, task in pairs(group.tasks) do
        if not task.used then
            TodolooTaskManagement_FreeTask(self, group, task)
        end
    end
end

function TodolooTaskManagement_FreeTask(self, group, task)
    group.tasks[task.id] = nil
    tinsert(self.freeTasks, task)

    task:Hide()
end

function TodolooTaskManagement_GetTask(self, group, id)
    local task = group.tasks[id]
    
    if task then
        task.used = true
        return task
    end

    local numFreeTasks = #self.freeTasks
    if numFreeTasks > 0 then
        task = self.freeTasks[numFreeTasks]
        tremove(self.freeTasks, numFreeTasks)
        task:SetParent(group)
        task:Show()
    else
        task = CreateFrame("Frame", nil, group, self.taskTemplate)
    end

    group.tasks[id] = task
    task.id = id
    task.used = true

    return task
end

function TodolooTaskManagement_AddTask(self, group, id, taskInfo)
    local task = TodolooTaskManagement_GetTask(self, group, id)

    if task.width ~= self.taskWidth then
        task:SetWidth(self.taskWidth)
        task.width = self.taskWidth
    end

    -- set task values
    task.Name:SetText(taskInfo.name)
    task.Reset:SetValue(taskInfo.reset)
    task.Reset:RegisterValueChangedCallback(TodolooTaskManagementGroup_OnResetValueChanged)

    -- save values for future reference
    task.name = taskInfo.name
    task.reset = taskInfo.reset

    --TODO: Set description
    task.description = taskInfo.description

    group.height = group.height + task:GetHeight() + self.taskSpacing

    -- anchor the task
    local yOffset = -self.taskSpacing
    if not self.firstTask then
        self.firstTask = task
        yOffset = 0
    end

    local anchor = group.currentTask or group.Name
    task:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset)

    group.currentTask = task
    return task
end

-- ***** UPDATE FUNCTIONS

function TodolooTaskManagement_BuildGroupInfos()
    local infos = {}

    for index, group in pairs(Todoloo.TaskManager.GetAll()) do
        table.insert(infos, { name = group.name, id = index })
    end

    return infos
end

function TodolooTaskManagement_EnumGroupData(self, func)
    local groupInfos = TodolooTaskManagement_BuildGroupInfos()

    for _, groupInfo in ipairs(groupInfos) do
        func(self, groupInfo)
    end
end

function TodolooTaskManagement_UpdateSingle(self, groupInfo)
    local group = TodolooTaskManagement_GetGroup(self, groupInfo.id)
    group.Name:SetText(groupInfo.name)
    group.name = groupInfo.name
    -- add tasks
    local numTasks = Todoloo.TaskManager.GetNumTasks(group.id)

    for taskIndex = 1, numTasks do
        local taskInfo = Todoloo.TaskManager.GetTask(group.id, taskIndex)
        if taskInfo then
            local task = TodolooTaskManagement_AddTask(self, group, taskIndex, taskInfo)
            task:Show()
        end
    end

    -- add button for new task
    local anchor = group.currentTask or group.Name

    local newTaskButton = self.newTaskButtonPool:Acquire()
    newTaskButton:SetParent(group)
    newTaskButton:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 13, -self.taskSpacing)
    newTaskButton:Show()

    group.height = group.height + newTaskButton:GetHeight()

    group:SetHeight(group.height)

    TodolooTaskManagement_AddGroup(self, group)
    group.used = true
    group:Show()
    TodolooTaskManagement_FreeUnusedTasks(self, group)
end

function TodolooTaskManagement_Update()
    local self = TodolooTaskManagementFrame

    -- we're already updating, try next frame
    if self.isUpdating then
        self.isUpdateDirty = true
        return
    end

    self.isUpdateDirty = true

    --TODO: Is the value ever used or are we only using groupsFrame.contentsHeight?
    self.contentsHeight = 0
    self.groupsFrame.currentGroup = nil
    self.groupsFrame.contentsHeight = 0

    TodolooTaskManagement_BeginLayout(self)

    TodolooTaskManagement_EnumGroupData(self, TodolooTaskManagement_UpdateSingle)

    TodolooTaskManagement_EndLayout(self)

    self.groupsFrame:SetHeight(self.groupsFrame.contentsHeight)
    self.groupsFrame:SetWidth(self.ScrollFrame:GetWidth())

    self.currentGroup = nil
    self.isUpdating = false
end

-- ***** SAVING

function TodolooTaskManagement_SaveChanges()
    local self = TodolooTaskManagementFrame

    -- save all groups
    local groups = self.usedGroups
    TodolooTaskManagement_SaveGroups(groups)

    -- update all tasks

    -- update tracker if visible
    local tracker = TodolooTrackerFrame
    if tracker:IsVisible() then
        TodolooTracker_Update()
    end
end

function TodolooTaskManagement_SaveGroups(groups)
    for _, group in pairs(groups) do
        if group.deleted then
            -- if the group has been deleted
            Todoloo.Debug.Message("Group " .. group.id .. " deleted")
            Todoloo.TaskManager.RemoveGroup(group.id)
            group.deleted = nil
        elseif group.hasUpdates then
            -- if the group is not deleted but has updates
            Todoloo.Debug.Message("Group " .. group.id .. " has updates")
            Todoloo.TaskManager.UpdateGroup(group.id, group.name)
            group.hasUpdates = false
        end

        if not group.deleted then
            TodolooTaskManagement_SaveTasks(group.id, group.tasks)
        end
    end
end

function TodolooTaskManagement_SaveTasks(groupId, tasks)
    for _, task in pairs(tasks) do
        if task.deleted then
            -- if the task has been deleted
            Todoloo.TaskManager.RemoveTask(groupId, task.id)
            task.deleted = nil
        elseif task.hasUpdates then
            -- if the task is not deleted but has updates
            Todoloo.TaskManager.UpdateTask(groupId, task.id, task.name, task.description, task.reset)
            task.hasUpdates = false
        end
    end
end

-- *****************************************************************************************************
-- ***** FRAME HANDLERS
-- *****************************************************************************************************

function TodolooTaskManagement_Initialize(self)
    --TODO: Remove function if nothing relevant during initialization
    self.initialized = true
end

function TodolooTaskManagement_OnLoad(self)
    self:SetParent(SettingsPanel or InterfaceOptionsFrame)
    self.name = "Todoloo"

    self.groupTemplate = "TodolooGroupConfigTemplate"
    self.taskTemplate = "TodolooTaskConfigTemplate"
    self.groupSpacing = 5
    self.taskWidth = 240 --TODO: Is this being used?
    self.taskSpacing = 0
    self.usedGroups = {}
    self.freeTasks = {}
    self.contentsHeight = 0

    self.groupsFrame = self.ScrollFrame.Content

    self.cancel = function()
        self:Cancel()
    end

    self.poolCollection = CreateFramePoolCollection()
    self.newTaskButtonPool = CreateFramePool("BUTTON", nil, "TodolooAddTaskButtonTemplate");

    -- add Todoloo category to addon settings
    if Settings and SettingsPanel then
        local category = Settings.RegisterCanvasLayoutCategory(self, self.name)
        category.ID = self.name
        Settings.RegisterAddOnCategory(category)
    else
        InterfaceOptions_AddCategory(self, self.name)
    end
end

function TodolooTaskManagement_OnShow(self)
    if not self.initialized then
        TodolooTaskManagement_Initialize(self)
    end

    -- show FirstTimeButton only if we're in debug mode
    if Todoloo.Config.Get(Todoloo.Config.Options.DEBUG) then
        self.FirstTimeButton:Show()
    end

    TodolooTaskManagement_Update()
end

function TodolooTaskManagement_OnHide(self)
    TodolooTaskManagement_SaveChanges()
end

-- *****************************************************************************************************
-- ***** GROUP UPDATE HANDLES
-- *****************************************************************************************************

function TodolooTaskManagementGroup_OnNameFocusLost(self)
    local group = self:GetParent()
    local newName = self:GetText()

    if newName ~= group.name then
        group.name = newName
        group.hasUpdates = true
    end
end

-- *****************************************************************************************************
-- ***** TASK UPDATE HANDLES
-- *****************************************************************************************************

function TodolooTaskManagementTask_OnNameFocusLost(self)
    local task = self:GetParent()
    local newName = self:GetText()

    if newName ~= task.name then
        task.name = newName
        task.hasUpdates = true
    end
end

function TodolooTaskManagementGroup_OnResetValueChanged(self)
    local task = self:GetParent()
    local newValue = self:GetValue()

    if newValue ~= task.reset then
        task.reset = newValue
        task.hasUpdates = true
    end
end

-- *****************************************************************************************************
-- ***** BUTTONS
-- *****************************************************************************************************

function TodolooTaskManagement_NewGroupButton_OnClick()
    TodolooTaskManagement_SaveChanges()
    Todoloo.TaskManager.AddGroup("")
    TodolooTaskManagement_Update()
end

function TodolooTaskManagement_ResetButton_OnClick()
    Todoloo.TaskManager.Reset()
    TodolooTaskManagement_Update()
end

function TodolooTaskManagement_FirstTimeButtonButton_OnClick()
    -- we really shouldn't do the first time setup unless we're in debug mode
    -- the button shouldn't even be visible
    if not Todoloo.Config.Get(Todoloo.Config.Options.DEBUG) then
        return
    end
    Todoloo.TaskManager.FirstTimeSetup()
    TodolooTaskManagement_Update()
end

function TodolooTaskManagementGroup_DeleteButton_OnClick(self)
    local group = self:GetParent()
    group.deleted = true
    
    TodolooTaskManagement_SaveChanges()
    TodolooTaskManagement_Update()
end

function TodolooTaskManagementGroup_AddTaskButton_OnClick(self)
    TodolooTaskManagement_SaveChanges()
    
    local group = self:GetParent()
    Todoloo.TaskManager.AddTask(group.id, "", nil, Todoloo.TaskManager.DefaultResetInterval)
    TodolooTaskManagement_Update()
end

function TodolooTaskManagementTask_DeleteButton_OnClick(self)
    local task = self:GetParent()

    task.deleted = true

    TodolooTaskManagement_SaveChanges()
    TodolooTaskManagement_Update()
end

TodolooDeleteButtonMixin = {}

function TodolooDeleteButtonMixin:OnEnter()
    self.Icon:SetAlpha(1.0);
end

function TodolooDeleteButtonMixin:OnLeave()
    self.Icon:SetAlpha(0.75);
end

function TodolooDeleteButtonMixin:OnMouseDown()
    self.Icon:SetPoint("TOPLEFT", 1, -1);
end

function TodolooDeleteButtonMixin:OnMouseUp()
    self.Icon:SetPoint("TOPLEFT", 0, 0);
end

-- *****************************************************************************************************
-- ***** DROPDOWN
-- *****************************************************************************************************

TodolooResetIntervalDropDownMixin = {}

function TodolooResetIntervalDropDownMixin:OnLoad()

end