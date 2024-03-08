-- *****************************************************************************************************
-- ***** MANAGEMENT PAGE
-- *****************************************************************************************************

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
    -- setup tutorial button
    self.HelpButton:SetScript("OnClick", function() self:ToggleHelp() end)
    
    -- setup button to create new group
    self.CreateGroupButton:SetTextToFit("Create group")

    -- setup search box
    self.TaskList.SearchBox:SetScript("OnTextChanged", function(editBox)
        SearchBoxTemplate_OnTextChanged(editBox)

        local text = editBox:GetText()
        if editBox ~= self.TaskList.SearchBox then
            self.TaskList.SearchBox:SetText(text)
        end

        Todoloo.TaskManager:OnTaskListSearchTextChanged(text)
    end)
end

function TodolooManagementPageMixin:Initialize(taskManagerInfo)
    self.taskManagerInfo = taskManagerInfo

    local searching = self.TaskList.SearchBox:HasText()
    local dataProvider = Todoloo.TaskManager:GenerateDataProvider(searching)

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
    Todoloo.EventBus:RegisterEvents(self, {
        Todoloo.Tasks.Events.GROUP_ADDED,
        Todoloo.Tasks.Events.GROUP_REMOVED,
        Todoloo.Tasks.Events.GROUP_RESET,
        Todoloo.Tasks.Events.GROUP_UPDATED,
        Todoloo.Tasks.Events.GROUP_MOVED,
        Todoloo.Tasks.Events.TASK_ADDED,
        Todoloo.Tasks.Events.TASK_REMOVED,
        Todoloo.Tasks.Events.TASK_UPDATED,
        Todoloo.Tasks.Events.TASK_LIST_UPDATE,
        Todoloo.Tasks.Events.TASK_MOVED,
        Todoloo.Tasks.Events.TASK_COMPLETION_SET,
        Todoloo.Tasks.Events.TASK_RESET,
    })
    
    self:SetTitle()
    self.TaskList.SearchBox:SetText(Todoloo.TaskManager:GetTaskNameFilter())
end

function TodolooManagementPageMixin:OnHide()
    if self:IsHelpShown() then
        HelpPlate_Hide(false)
    end
end

function TodolooManagementPageMixin:SetTitle()
    local taskManagementFrame = self:GetParent()
    taskManagementFrame:SetTitle("Todoloo - Task management")
end

function TodolooManagementPageMixin:CreateButtonGroup_OnClick()
    -- create new blank group
    Todoloo.TaskManager:AddGroup("")
end

-- ***** EVENT HANDLERS

function TodolooManagementPageMixin:ReceiveEvent(event, ...)
    local taskManagerInfo = Todoloo.TaskManager:GetTaskManagerInfo()

    if event == Todoloo.Tasks.Events.GROUP_ADDED then
        local groupId = ...
        taskManagerInfo.openGroupId = groupId

        self:Refresh(taskManagerInfo)
    elseif event == Todoloo.Tasks.Events.TASK_ADDED then
        local groupId, taskId = ...
        taskManagerInfo.openTask = { taskId = taskId, groupId = groupId }

        self:Refresh(taskManagerInfo)
    else
        self:Refresh(taskManagerInfo)
    end
end

-- ***** HELP

TodolooTaskManagerManagementPage_HelpPlate = 
{
    FramePos = { x = 5, y = -22 }
}

---Build the help guide
function TodolooManagementPageMixin:UpdateHelp()
    TodolooTaskManagerManagementPage_HelpPlate.FrameSize = { width = 400 , height = 635 }

    if self.CreateGroupButton:IsShown() then
        local width = self.CreateGroupButton:GetWidth()
        local height = self.CreateGroupButton:GetHeight()
        table.insert(TodolooTaskManagerManagementPage_HelpPlate, { ButtonPos = { x = 235, y = -11 }, HighLightBox = { x = 256, y = -21, width = width + 16, height = height + 5 }, ToolTipDir = "LEFT", ToolTipText = "Create a new group to get started with your task management!" })
    end

    if self.TaskList:IsShown() then
        table.insert(TodolooTaskManagerManagementPage_HelpPlate, { ButtonPos = { x = 170, y = -44 }, HighLightBox = { x = 0, y = -52, width = 390, height = 30 }, ToolTipDir = "DOWN", ToolTipText = "Tip: Search for a specific task or group to find the item you are looking for more easily." })
        table.insert(TodolooTaskManagerManagementPage_HelpPlate, { ButtonPos = { x = 365, y = -80 }, HighLightBox = { x = 0, y = -85, width = 390, height = 545 }, ToolTipDir = "RIGHT", ToolTipText = "This is your overview of all your current groups and tasks.\n\n[Double-Click] on groups and tasks to change the name.\n\n[Shift]+[Left-Click] on groups to collapse.\n\n[Right-Click] on groups to add tasks and delete.\n\n[Shift]+[Left-Click] on tasks to toggle completion.\n\n[Right-Click] on tasks to set reset interval and delete." })
    end
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