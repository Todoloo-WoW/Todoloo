-- *****************************************************************************************************
-- ***** MANAGEMENT PAGE
-- *****************************************************************************************************

---Find task info in the dataprovider by the given task ID
---@param dataProvider any
---@param taskId integer Task ID (is equal to the task index within the group in Todoloo tasks)
---@return any
local function FindTaskInfo(dataProvider, taskId, groupId, character)
    if not taskId then
        return nil
    end

    local function IsTaskMatchPredicate(node)
        local data = node:GetData()
        local taskInfo = data.taskInfo
        return taskInfo and taskInfo.id == taskId and taskInfo.groupId == groupId and taskInfo.character == character
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
local function FindGroupInfo(dataProvider, groupId, character)
    if not groupId then
        return nil
    end

    local function IsGroupMatchPredicate(node)
        local data = node:GetData()
        local groupInfo = data.groupInfo
        return groupInfo and groupInfo.id == groupId and groupInfo.character == character
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
    self.CreateGroupButton:SetTextToFit(TODOLOO_L_TASK_MANAGER_BUTTON_CREATE_GROUP)

    -- setup search box
    self.TaskList.SearchBox:SetScript("OnTextChanged", function(editBox)
        SearchBoxTemplate_OnTextChanged(editBox)

        local text = editBox:GetText()
        if editBox ~= self.TaskList.SearchBox then
            self.TaskList.SearchBox:SetText(text)
        end

        Todoloo.Tasks.OnTaskListSearchTextChanged(text)
    end)
end

function TodolooManagementPageMixin:Initialize(taskManagerInfo)
    self.taskManagerInfo = taskManagerInfo

    local searching = self.TaskList.SearchBox:HasText()
    local dataProvider = Todoloo.Tasks.GenerateTaskDataProvider(searching)

    if searching then
        self.TaskList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)
    else
        self.TaskList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
    end
    self.TaskList.NoResultsText:SetShown(dataProvider:IsEmpty())

    -- if the task manager tells us to open a specific task in edit mode
    local currentTaskInfo = nil
    if taskManagerInfo.openTask then
        currentTaskInfo = FindTaskInfo(dataProvider, taskManagerInfo.openTask.taskId, taskManagerInfo.openTask.groupId, taskManagerInfo.openTask.character)
        local scrollToTask = true
        self.TaskList:OpenTask(currentTaskInfo, scrollToTask)
    end

    -- if the task manager tells us to open a specific group in edit mode
    local currentGroupInfo = nil
    if taskManagerInfo.openGroup then
        currentGroupInfo = FindGroupInfo(dataProvider, taskManagerInfo.openGroup.groupId, taskManagerInfo.openGroup.character)
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
        Todoloo.Tasks.Events.FILTER_CHANGED
    })
    
    self:SetTitle()
    self.TaskList.SearchBox:SetText(Todoloo.Tasks.GetTaskListSearchText())
end

function TodolooManagementPageMixin:OnHide()
    if self:IsHelpShown() then
        HelpPlate_Hide(false)
    end
end

function TodolooManagementPageMixin:SetTitle()
    local taskManagementFrame = self:GetParent()
    taskManagementFrame:SetTitle(TODOLOO_L_TASK_MANAGER_FRAME_HEADER)
end

function TodolooManagementPageMixin:CreateButtonGroup_OnClick()
    Todoloo.TaskManager:AddGroup("")
end

-- ***** EVENT HANDLERS

function TodolooManagementPageMixin:ReceiveEvent(event, ...)
    local taskManagerInfo = {}

    if event == Todoloo.Tasks.Events.GROUP_ADDED then
        --TODO: This needs to be able to handle multiple characters
        local groupId, character = ...
        taskManagerInfo.openGroup = { groupId = groupId, character = character }

        self:Refresh(taskManagerInfo)
    elseif event == Todoloo.Tasks.Events.TASK_ADDED then
        --TODO: This needs to be able to handle multiple characters
        local groupId, taskId, character = ...
        taskManagerInfo.openTask = { taskId = taskId, groupId = groupId, character = character }

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
        table.insert(TodolooTaskManagerManagementPage_HelpPlate, { ButtonPos = { x = 235, y = -11 }, HighLightBox = { x = 256, y = -21, width = width + 16, height = height + 5 }, ToolTipDir = "LEFT", ToolTipText = TODOLOO_L_TASK_MANAGER_HELP_CREATE_GROUP_HELP })
    end

    if self.TaskList:IsShown() then
        table.insert(TodolooTaskManagerManagementPage_HelpPlate, { ButtonPos = { x = 170, y = -44 }, HighLightBox = { x = 0, y = -52, width = 390, height = 30 }, ToolTipDir = "DOWN", ToolTipText = TODOLOO_L_TASK_MANAGER_HELP_FILTER_TIP })
        table.insert(TodolooTaskManagerManagementPage_HelpPlate, { ButtonPos = { x = 365, y = -80 }, HighLightBox = { x = 0, y = -85, width = 390, height = 545 }, ToolTipDir = "RIGHT", ToolTipText = TODOLOO_L_TASK_MANAGER_HELP_TASK_LIST_HELP })
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