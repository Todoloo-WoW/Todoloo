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
---@param taskId integer Task ID (is equal to the task index within the group in TODOLOO_TASKS[character].groups)
---@return any
local function FindTaskInfo(dataProvider, taskId)
    if not taskId then
        return nil
    end

    local function IsTaskMatchPredicate(node)
        local data = node:GetData()
        local taskInfo = data.taskInfo
        return taskInfo and taskInfo.taskId == taskId
    end

    local node = dataProvider:FindElementDataByPredicate(IsTaskMatchPredicate, TreeDataProviderConstants.IncludeCollapsed)

    if node then
        local data = node:GetDate()
        return data.taskInfo
    end
end

TodolooManagementPageMixin = {}

function TodolooManagementPageMixin:OnLoad()
    -- setup search box
    self.TaskList.SearchBox:SetScript("OnTextChanged", function(editBox)
        --TODO: Implement searching
    end)

    -- setup tutorial button
    self.TutorialButton:SetScript("OnClick", function() self:ToggleTutorial() end)
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
    --self.TaskList.NoResultsText:SetShown(dataProvider:IsEmpty())

    --[[ Because we're rebuilding the data provider, we need to either make an initial selection or
    reselct the task we previously had selected.--]]
    local currentTaskInfo = nil
    --TODO: Implement functionality to reopen the lastest opened task, using taskManagerInfo.openTaskId
    local openTaskId = nil --taskManagerInfo.openTaskId
    if openTaskId then
        currentTaskInfo = FindTaskInfo(dataProvider, openTaskId)
    else
        currentTaskInfo = FindFirstTask(dataProvider)
    end

    local scrollToTask = openTaskId ~= nil
    self.TaskList:SelectTask(currentTaskInfo, scrollToTask)
end

function TodolooManagementPageMixin:ToggleTutorial()
    --TODO: Implement tutorial
end

function TodolooManagementPageMixin:Refresh(taskManagerInfo)
    if self:IsVisible() then
        self:SetTitle()
    end

    self:Initialize(taskManagerInfo)

    self.TaskList:Show()

    -- local taskWidth = 500
    -- self.TaskForm:SetWidth(taskWidth)

    self.TaskForm.Background:SetAtlas("Professions-Recipe-Background-Inscription", TextureKitConstants.IgnoreAtlasSize)
    self.TaskForm.Background:Show();
    self.TaskForm.MinimalBackground:Hide();
end

function TodolooManagementPageMixin:OnShow()
    self:SetTitle()
end

function TodolooManagementPageMixin:SetTitle()
    local taskManagementFrame = self:GetParent()
    taskManagementFrame:SetTitle("Todoloo - Task management")
end