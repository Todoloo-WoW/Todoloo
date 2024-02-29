-- *****************************************************************************************************
-- ***** MANAGEMENT PAGE
-- *****************************************************************************************************

---Find the first task in the data provider
---@param dataProvider any
---@return any
local function FindFirstTask(dataProvider)
    for _, node in dataProvider:EnumerateEntireRange() do
        local data = node:GetData()
        local taskInfo = data.taskInfo

        if taskInfo then
            return taskInfo
        end
    end
end

---Find task info in the dataprovider by the given task ID
---@param dataProvider any
---@param taskId integer Task ID (is equal to the task index within the group in Todoloo tasks)
---@return any
local function FindTaskInfo(dataProvider, taskId, groupId)
    if not taskId then
        return nil
    end

    local function IsTaskMatchPredicate(node)
        local data = node:GetData()
        local taskInfo = data.taskInfo
        return taskInfo and taskInfo.id == taskId and taskInfo.groupId == groupId
    end

    local node = dataProvider:FindElementDataByPredicate(IsTaskMatchPredicate, TreeDataProviderConstants.IncludeCollapsed)

    if node then
        local data = node:GetData()
        return data.taskInfo
    end
end

---Find group info in the dataprovider by the given group ID
---@param dataProvider any
---@param groupId integer Group ID (is equal to the groupButton index within the character in Todoloo tasks)
---@return any
local function FindGroupInfo(dataProvider, groupId)
    if not groupId then
        return nil
    end

    local function IsGroupMatchPredicate(node)
        local data = node:GetData()
        local groupInfo = data.groupInfo
        return groupInfo and groupInfo.id == groupId
    end

    local node = dataProvider:FindElementDataByPredicate(IsGroupMatchPredicate, TreeDataProviderConstants.IncludeCollapsed)

    if node then
        local data = node:GetData()
        return data.groupInfo
    end
end

TodolooManagementPageMixin = {}

function TodolooManagementPageMixin:OnLoad()
    -- setup search box
    self.TaskList.SearchBox:SetScript("OnTextChanged", function(editBox)
        --TODO: Implement searching
    end)

    -- setup tutorial button
    self.HelpButton:SetScript("OnClick", function() self:ToggleHelp() end)
    
    -- setup button to create new group
    self.CreateGroupButton:SetTextToFit("Create group")

    EventRegistry:RegisterCallback("TodolooTaskListGroupMixin.Event.OnGroupSaved", self.OnGroupSaved, self)
    EventRegistry:RegisterCallback("TodolooTaskListTaskMixin.Event.OnTaskSaved", self.OnTaskSaved, self)
    EventRegistry:RegisterCallback("TodolooTaskListMixin.Event.OnGroupDeleted", self.OnGroupDeleted, self)
    EventRegistry:RegisterCallback("TodolooTaskListMixin.Event.OnTaskDeleted", self.OnTaskDeleted, self)
    EventRegistry:RegisterCallback("TodolooTaskListMixin.Event.OnTaskCreated", self.OnTaskCreated, self)
    EventRegistry:RegisterCallback("TodolooTaskListMixin.Event.OnTaskUpdated", self.OnTaskUpdated, self)
end

function TodolooManagementPageMixin:Initialize(taskManagerInfo)
    self.taskManagerInfo = taskManagerInfo

    local searching = self.TaskList.SearchBox:HasText()
    local dataProvider = Todoloo.TaskManager.GenerateDataProvider()

    if searching then
        self.TaskList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)
    else
        self.TaskList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
    end
    self.TaskList.NoResultsText:SetShown(dataProvider:IsEmpty())

    -- if the task manager tells us to open a specific task in edit mode
    local currentTaskInfo = nil
    if taskManagerInfo.openTask then
        currentTaskInfo = FindTaskInfo(dataProvider, taskManagerInfo.openTask.taskId, taskManagerInfo.openTask.groupId)
        local scrollToTask = true
        self.TaskList:OpenTask(currentTaskInfo, scrollToTask)
    end

    -- if the task manager tells us to open a specific group in edit mode
    local currentGroupInfo = nil
    if taskManagerInfo.openGroupId then
        currentGroupInfo = FindGroupInfo(dataProvider, taskManagerInfo.openGroupId)
        local scrollToTask = true
        self.TaskList:OpenGroup(currentGroupInfo, scrollToTask)
    end
end

function TodolooManagementPageMixin:Refresh(taskManagerInfo)
    if self:IsVisible() then
        self:SetTitle()
    end

    self:Initialize(taskManagerInfo)
end

function TodolooManagementPageMixin:OnShow()
    self:SetTitle()
end

function TodolooManagementPageMixin:SetTitle()
    local taskManagementFrame = self:GetParent()
    taskManagementFrame:SetTitle("Todoloo - Task management")
end

function TodolooManagementPageMixin:CreateButtonGroup_OnClick()
    -- create new blank group
    local _, groupId = Todoloo.TaskManager.AddGroup("")

    local taskManagerInfo = Todoloo.TaskManager.GetTaskManagerInfo()
    taskManagerInfo.openGroupId = groupId

    self:Refresh(taskManagerInfo)
end

-- ***** EVENT HANDLERS

function TodolooManagementPageMixin:OnGroupSaved(groupInfo, taskList)
    print("OnGroupSaved")
    -- TODO: Ensure that it's our task list
    -- this is not our task list
    -- print(self.TaskList)
    -- print(taskList)
    -- if taskList ~= nil and taskList ~= self.TaskList then
    --     return
    -- end

    local taskManagerInfo = Todoloo.TaskManager.GetTaskManagerInfo()

    self:Refresh(taskManagerInfo)

    -- TODO: Fire event that task tracker listenes to
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end

function TodolooManagementPageMixin:OnGroupDeleted(taskList)
    print("OnGroupDeleted")

    local taskManagerInfo = Todoloo.TaskManager.GetTaskManagerInfo()

    self:Refresh(taskManagerInfo)

    -- TODO: Fire event that task tracker listenes to
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end

function TodolooManagementPageMixin:OnTaskCreated(task, taskId, groupId)
    print("OnTaskCreated")

    local taskManagerInfo = Todoloo.TaskManager.GetTaskManagerInfo()
    taskManagerInfo.openTask = { taskId = taskId, groupId = groupId }

    self:Refresh(taskManagerInfo)

    -- TODO: Fire event that task tracker listenes to
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end

function TodolooManagementPageMixin:OnTaskUpdated(taskInfo, taskList)
    print("OnTaskUpdated")

    local taskManagerInfo = Todoloo.TaskManager.GetTaskManagerInfo()
    
    self:Refresh(taskManagerInfo)

    -- TODO: Fire event that task tracker listenes to
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end

function TodolooManagementPageMixin:OnTaskSaved(taskInfo, taskList)
    print("OnTaskSaved")

    local taskManagerInfo = Todoloo.TaskManager.GetTaskManagerInfo()
    
    self:Refresh(taskManagerInfo)

    -- TODO: Fire event that task tracker listenes to
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end

function TodolooManagementPageMixin:OnTaskDeleted(taskInfo, taskList)
    print("OnTaskDeleted")

    local taskManagerInfo = Todoloo.TaskManager.GetTaskManagerInfo()

    self:Refresh(taskManagerInfo)

    -- TODO: Fire event that task tracker listenes to
    if TodolooTrackerFrame and TodolooTrackerFrame:IsVisible() then
        TodolooTracker_Update()
    end
end


-- ***** HELP

TodolooTaskManagerManagementPage_HelpPlate = 
{
    FramePos = { x = 5, y = -22 }
}

---Build the help guide
---TODO: Add relevant help guides
function TodolooManagementPageMixin:UpdateHelp()
    TodolooTaskManagerManagementPage_HelpPlate.FrameSize = { width = 786, height = 635 }

    -- if self.TaskList:IsShown() then
    --     table.insert(TodolooTaskManagerManagementPage_HelpPlate, { ButtonPos = { x = 125, y = -44 }, HighLightBox = { x = 0, y = -52, width = 271, height = 30 }, ToolTipDir = "DOWN", ToolTipText = "TEST" })
    -- end
end

---Show the help guide
function TodolooManagementPageMixin:ShowHelp()
    self:UpdateHelp()
    HelpPlate_Show(TodolooTaskManagerManagementPage_HelpPlate, self, self.HelpButton)
end

---Is the help guide currently being shown?
---@return boolean
function TodolooManagementPageMixin:IsHelpShown()
    return HelpPlate_IsShowing(TodolooTaskManagerManagementPage_HelpPlate)
end

---Toggle the help guide. This automatically shows the hel guide if currently not shown, and hides if shown
function TodolooManagementPageMixin:ToggleHelp()
    if not self:IsHelpShown() then
        self:ShowHelp()
    else
        HelpPlate_Hide(true)
    end
end