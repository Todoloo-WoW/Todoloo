-- *****************************************************************************************************
-- ***** MANAGEMENT PAGE
-- *****************************************************************************************************

local function ClearDiscardConfirmation(_, data)
    if data and data.page.pendingDiscard == data then
        data.page.pendingDiscard = nil
    end
end

StaticPopupDialogs["TODOLOO_DISCARD_TASK_CHANGES"] = {
    text = TODOLOO_L_TASK_DETAILS_UNSAVED_CHANGES_DIALOG_DESCRIPTION,
    button1 = TODOLOO_L_TASK_DETAILS_UNSAVED_CHANGES_DIALOG_CONFIRM_BUTTON,
    button2 = CANCEL,

    OnAccept = function(_, data)
        local page = data.page

        if page.pendingDiscard ~= data then
            return
        end

        page.pendingDiscard = nil

        if not page:IsVisible() or page.Details:GetDraft() ~= data.draft then
            return
        end

        page.Details:ResetDraft()
        data.action()
    end,

    OnCancel = ClearDiscardConfirmation,
    OnHide = ClearDiscardConfirmation,

    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    hideOnEscape = 1
}

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

local function FindTaskAfterRemoval(oldProvider, newProvider, removedTask)
    local available = {}
    local firstTask

    for _, node in newProvider:EnumerateEntireRange() do
        local info = node:GetData().taskInfo
        if info then
            available[info.taskRef] = true
            firstTask = firstTask or info.taskRef
        end
    end

    if not oldProvider then
        return firstTask
    end

    local previousTask
    local foundRemovedTask = false

    for _, node in oldProvider:EnumerateEntireRange() do
        local info = node:GetData().taskInfo

        if info then
            local task = info.taskRef

            if task == removedTask then
                foundRemovedTask = true
            elseif available[task] then
                if foundRemovedTask then
                    return task
                end

                previousTask = task
            end
        end
    end

    if foundRemovedTask then
        return previousTask or firstTask
    end

    return firstTask
end

local function FindFirstTask(dataProvider)
    for _, node in dataProvider:EnumerateEntireRange() do
        local data = node:GetData()
        local taskInfo = data.taskInfo
        if taskInfo then
            return taskInfo
        end
    end
end

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
    local atlas = "Professions-Recipe-Background-Inscription"
    if not C_Texture.GetAtlasInfo(atlas) then
        atlas = "Professions-Recipe-Background"
    end

    self.managementEvents = {
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
    }

    self.Details.Background:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize)
    self.Details.Background:Show()

    self.HelpButton:SetScript("OnClick", function() self:ToggleHelp() end)
    
    self.CreateGroupButton:SetTextToFit(TODOLOO_L_TASK_MANAGER_BUTTON_CREATE_GROUP)

    self.TaskList.SearchBox:SetScript("OnTextChanged", function(editBox)
        SearchBoxTemplate_OnTextChanged(editBox)

        local text = editBox:GetText()
        if editBox ~= self.TaskList.SearchBox then
            self.TaskList.SearchBox:SetText(text)
        end

        Todoloo.Tasks.OnTaskListSearchTextChanged(text)
    end)

    self.Details:SetDraftChangedCallback(function()
        self:UpdateActionButtons()
    end)

    self:SelectTask(nil)

    self.CreateGroupButton:SetScript("OnClick", function()
        Todoloo.TaskManager:AddGroup(TODOLOO_L_TASK_MANAGER_DEFAULT_GROUP_NAME)
    end)

    self.SaveButton:SetScript("OnClick", GenerateClosure(self.Save, self))
    self.ResetButton:SetScript("OnClick", GenerateClosure(self.Reset, self))
end

function TodolooManagementPageMixin:Initialize(taskManagerInfo)
    self.taskManagerInfo = taskManagerInfo

    local searching = self.TaskList.SearchBox:HasText()
    local dataProvider = Todoloo.Tasks.GenerateTaskDataProvider(searching)
    local selectAfterRemoval = false

    if taskManagerInfo.removal and self.selectedTask then
        local _, _, group = self.Details:GetTaskLocation()

        if not group then
            local nextTask = FindTaskAfterRemoval(
                self.TaskList.ScrollBox:GetDataProvider(),
                dataProvider,
                self.selectedTask
            )

            self:SelectTask(nil)
            self.selectedTask = nextTask
            selectAfterRemoval = true
        end
    end

    self.TaskList:ApplyCollapsedState(dataProvider, searching)

    if searching then
        self.TaskList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)
    else
        self.TaskList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
    end

    self.TaskList.NoResultsText:SetShown(dataProvider:IsEmpty())

    if taskManagerInfo.openTask then
        local request = taskManagerInfo.openTask
        local taskInfo = FindTaskInfo(dataProvider, request.taskId, request.groupId, request.character)

        if taskInfo then
            self:RequestTaskSelection(taskInfo.taskRef, true)
            return
        end
    end

    local groupToReveal
    if taskManagerInfo.openGroup then
        local request = taskManagerInfo.openGroup
        groupToReveal = FindGroupInfo(dataProvider, request.groupId, request.character)
    end

    if not self.selectedTask then
        local firstTaskInfo = FindFirstTask(dataProvider)
        self.selectedTask = firstTaskInfo and firstTaskInfo.taskRef or nil
    end

    if selectAfterRemoval and self.selectedTask then
        self:RequestTaskSelection(self.selectedTask, true)
    else
        self.TaskList:RestoreTaskSelection(self.selectedTask)
    end

    if groupToReveal then
        self.TaskList:RevealGroup(groupToReveal, true)
    end
end

function TodolooManagementPageMixin:SelectTask(taskInfo)
    self.selectedTask = taskInfo and taskInfo.taskRef or nil
    self.Details:Init(taskInfo)
end

function TodolooManagementPageMixin:Refresh(taskManagerInfo)
    if self:IsVisible() then
        self:SetTitle()
    end

    self:Initialize(taskManagerInfo)
end

function TodolooManagementPageMixin:OnShow()
    if not self.eventsRegistered then
        Todoloo.EventBus:RegisterEvents(self, self.managementEvents)
        self.eventsRegistered = true
    end
    
    self:SetTitle()
    self.TaskList.SearchBox:SetText(Todoloo.Tasks.GetTaskListSearchText())
end

function TodolooManagementPageMixin:OnHide()
    if self.eventsRegistered  then
        Todoloo.EventBus:UnregisterEvents(self, self.managementEvents)
        self.eventsRegistered = false
    end

    local pending = self.pendingDiscard
    self.pendingDiscard = nil

    if pending then
        StaticPopup_Hide("TODOLOO_DISCARD_TASK_CHANGES", pending)
    end

    if self:IsHelpShown() then
        HelpPlate.Hide(false)
    end
end

function TodolooManagementPageMixin:SetTitle()
    local taskManagementFrame = self:GetParent()
    taskManagementFrame:SetTitle(TODOLOO_L_TASK_MANAGER_FRAME_HEADER)
end

function TodolooManagementPageMixin:UpdateActionButtons()
    local hasChanges = self.Details:HasUnsavedChanges()

    self.SaveButton:SetEnabled(hasChanges)
    self.ResetButton:SetEnabled(hasChanges)
end

function TodolooManagementPageMixin:RequestTaskSelection(taskRef, scrollToTask)
    if not taskRef then
        return
    end

    local function SelectRequestedTask()
        local scrollBox = self.TaskList.ScrollBox
        local dataProvider = scrollBox:GetDataProvider()

        local node = dataProvider:FindElementDataByPredicate(
            function(candidate)
                local info = candidate:GetData().taskInfo
                return info and info.taskRef == taskRef
            end,
            TreeDataProviderConstants.IncludeCollapsed
        )

        if not node then
            return
        end

        local parent = node:GetParent()
        while parent do
            if parent:IsCollapsed() then
                self.TaskList:SetNodeCollapsed(parent, false)
            end

            parent = parent:GetParent()
        end

        if scrollToTask then
            scrollBox:ScrollToElementData(node)
        end

        self.TaskList.selectionBehavior:SelectElementData(node)
    end

    if taskRef == self.selectedTask then
        SelectRequestedTask()
    else
        self:ConfirmDiscardChanges(SelectRequestedTask)
    end
end

function TodolooManagementPageMixin:RefreshProgress()
    self.TaskList:RefreshProgress()
    self.Details:RefreshSummary()
end

function TodolooManagementPageMixin:Save()
    local taskInfo = self.Details:GetTaskInfo()
    local draft = self.Details:GetDraft()

    if not taskInfo or not draft then
        return false
    end

    local groupId, taskId, group = self.Details:GetTaskLocation()
    if not group then
        return false
    end

    local name = draft.name:match("^%s*(.-)%s*$")

    if name == "" then
        UIErrorsFrame:AddMessage(TODOLOO_L_TASK_DETAILS_FORM_ERROR_TITLE_REQUIRED, 1, 0.2, 0.2)
        self.Details.Name:SetFocus()
        return false
    end

    local description = draft.description
    if description == "" then
        description = nil
    end

    local reset
    if group.reset == nil then
        reset = draft.reset
    end

    local target = tonumber(draft.target)
    if not target or target < 1 or target % 1 ~= 0 then
        UIErrorsFrame:AddMessage(TODOLOO_L_TASK_DETAILS_FORM_ERROR_TARGET_INVALID, 1, 0.2, 0.2)
        self.Details.Target:SetFocus()
        self.Details.Target:HighlightText()
        return false
    end

    local task = taskInfo.taskRef

    self.isSaving = true

    local success, saveError = pcall(function()
        Todoloo.TaskManager:UpdateTask(
            groupId,
            taskId,
            name,
            description,
            reset,
            taskInfo.character
        )

        Todoloo.TaskManager:SetTaskTarget(
            groupId,
            taskId,
            target,
            taskInfo.character
        )

        Todoloo.TaskManager:SetTaskLootItems(
            groupId,
            taskId,
            draft.lootItemIDs,
            taskInfo.character
        )
    end)

    self.isSaving = nil

    if not success then
        error(saveError, 0)
    end

    local currentInfo = self.Details:GetTaskInfo()
    if currentInfo and currentInfo.taskRef == task then
        self.Details:ResetDraft()
    end

    self:Refresh({})

    return true
end

function TodolooManagementPageMixin:Reset()
    self.Details:ResetDraft()
end

function TodolooManagementPageMixin:ConfirmDiscardChanges(action)
    if self.pendingDiscard then
        return false
    end

    if not self.Details:HasUnsavedChanges() then
        action()
        return true
    end

    local data = {
        page = self,
        draft = self.Details:GetDraft(),
        action = action
    }

    self.pendingDiscard = data

    local dialog = StaticPopup_Show("TODOLOO_DISCARD_TASK_CHANGES", nil, nil, data)
    if not dialog then
        self.pendingDiscard = nil
    end

    return false
end

function TodolooManagementPageMixin:ReceiveEvent(event, ...)
    if self.isSaving and event == Todoloo.Tasks.Events.TASK_UPDATED then
        return
    end

    if event == Todoloo.Tasks.Events.TASK_UPDATED then
        local groupId, taskId, character = ...

        if self.TaskList:IsTaskProgressUpdate(groupId, taskId, character) then
            self:RefreshProgress()
            return
        end
    elseif event == Todoloo.Tasks.Events.TASK_COMPLETION_SET
        or event == Todoloo.Tasks.Events.TASK_RESET
        or event == Todoloo.Tasks.Events.GROUP_RESET then
        self:RefreshProgress()
        return
    end

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
    elseif event == Todoloo.Tasks.Events.TASK_REMOVED or event == Todoloo.Tasks.Events.GROUP_REMOVED then
        taskManagerInfo.removal = true
        self:Refresh(taskManagerInfo)
    else
        self:Refresh(taskManagerInfo)
    end
end

TodolooTaskManagerManagementPage_HelpPlate = 
{
    FramePos = { x = 5, y = -22 }
}

---Build the help guide
function TodolooManagementPageMixin:UpdateHelp()
    local helpInfo = TodolooTaskManagerManagementPage_HelpPlate
    wipe(helpInfo)

    local helpScale = HelpPlate.GetEffectiveScale()
    local pageScale = self:GetEffectiveScale()

    local pageLeft = self:GetLeft() * pageScale
    local pageTop = self:GetTop() * pageScale

    helpInfo.FramePos = { x = 0, y = 0 }
    helpInfo.FrameSize = {
        width = self:GetWidth() * pageScale / helpScale,
        height = self:GetHeight() * pageScale / helpScale
    }

    local function GetRect(frame)
        if not frame:IsVisible() then
            return
        end

        local scale = frame:GetEffectiveScale()

        return {
            x = (frame:GetLeft() * scale - pageLeft) / helpScale,
            y = (frame:GetTop() * scale - pageTop) / helpScale,
            width = frame:GetWidth() * scale / helpScale,
            height = frame:GetHeight() * scale / helpScale
        }
    end

    local function AddHelp(frame, text, direction, lastFrame)
        local rect = GetRect(frame)
        if not rect then
            return
        end

        local other = lastFrame and GetRect(lastFrame)

        if other then
            local right = math.max(rect.x + rect.width, other.x + other.width)
            local bottom = math.min(rect.y - rect.height, other.y - other.height)

            rect.x = math.min(rect.x, other.x)
            rect.y = math.min(rect.y, other.y)
            rect.width = right - rect.x
            rect.height = rect.y - bottom
        end

        table.insert(helpInfo, {
            ButtonPos = {
                x = rect.x + math.max(0, rect.width - 40),
                y = rect.y + 6
            },
            HighLightBox = rect,
            ToolTipDir = direction,
            ToolTipText = text
        })
    end

    AddHelp(
        self.CreateGroupButton,
        TODOLOO_L_TASK_MANAGER_HELP_CREATE_GROUP_HELP,
        "DOWN"
    )

    AddHelp(
        self.TaskList.SearchBox,
        TODOLOO_L_TASK_MANAGER_HELP_FILTERS,
        "DOWN",
        self.TaskList.FilterButton
    )

    AddHelp(
        self.TaskList.ScrollBox,
        TODOLOO_L_TASK_MANAGER_HELP_TASK_LIST_INTERACTIONS,
        "RIGHT"
    )

    AddHelp(
        self.Details,
        TODOLOO_L_TASK_MANAGER_HELP_TASK_DETAILS,
        "RIGHT"
    )

    AddHelp(
        self.ResetButton,
        TODOLOO_L_TASK_MANAGER_HELP_SAVE_RESET,
        "UP",
        self.SaveButton
    )
end

function TodolooManagementPageMixin:ShowHelp()
    self:UpdateHelp()
    HelpPlate.Show(TodolooTaskManagerManagementPage_HelpPlate, self, self.HelpButton)
end

function TodolooManagementPageMixin:IsHelpShown()
    return HelpPlate.IsShowingHelpInfo(TodolooTaskManagerManagementPage_HelpPlate)
end

function TodolooManagementPageMixin:ToggleHelp()
    if not self:IsHelpShown() then
        self:ShowHelp()
    else
        HelpPlate.Hide(true)
    end
end