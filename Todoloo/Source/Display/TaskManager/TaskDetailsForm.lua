local function CreateDraft(task)
    return {
        name = task.name or "",
        description = task.description or "",
        reset = task.reset or TODOLOO_DEFAULT_RESET_INTERVAL,
        target = tostring(task.target or 1)
    }
end

TodolooTaskDetailsFormMixin = {}

function TodolooTaskDetailsFormMixin:OnLoad()
    self.Manual.resetInterval = TODOLOO_RESET_INTERVALS.Manually
    self.Daily.resetInterval = TODOLOO_RESET_INTERVALS.Daily
    self.Weekly.resetInterval = TODOLOO_RESET_INTERVALS.Weekly

    self.resetButtons = {
        self.Manual,
        self.Daily,
        self.Weekly
    }

    for _, button in ipairs(self.resetButtons) do
        button:SetScript("OnClick", function(clickedButton)
            if self.draft and self.groupReset == nil then
                self.draft.reset = clickedButton.resetInterval
            end

            self:RefreshResetButtons()
            self:NotifyDraftChanged()
        end)
    end

    self.Name:HookScript("OnTextChanged", function(editBox)
        if not self.draft then
            return
        end

        self.draft.name = editBox:GetText()
        self:NotifyDraftChanged()
    end)

    self.Name:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)

    self.Description.EditBox:HookScript("OnTextChanged", function(editBox)
        if not self.draft then
            return
        end

        self.draft.description = editBox:GetText()
        self:NotifyDraftChanged()
    end)

    self.Description.EditBox:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)

    self.Target:SetMinMaxValues(1, nil)
    self.Target:HookScript("OnHide", function(spinner)
        spinner:EndIncrement()
    end)

    self.Target:HookScript("OnTextChanged", function(editBox)
        if not self.draft then
            return
        end

        self.draft.target = editBox:GetText()
        self:NotifyDraftChanged()
    end)

    self.Target:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)
end

function TodolooTaskDetailsFormMixin:OnShow()
    local taskInfo = self:GetTaskInfo()
    if taskInfo then
        self:Init(taskInfo)
    end
end

function TodolooTaskDetailsFormMixin:Init(taskInfo)
    local previousTask = self.currentTaskInfo and self.currentTaskInfo.taskRef
    self.currentTaskInfo = taskInfo

    self.Header:Hide()
    self.Summary:Hide()
    self.NameLabel:Hide()
    self.DescriptionLabel:Hide()
    self.ResetIntervalLabel:Hide()
    self.TargetLabel:Hide()

    self.Name:Hide()
    self.Description:Hide()
    self.Manual:Hide()
    self.Daily:Hide()
    self.Weekly:Hide()
    self.Target:Hide()
    
    local task = taskInfo and taskInfo.taskRef
    local hasTask = task ~= nil

    if not hasTask then
        self.Header:SetText(TODOLOO_L_TASK_DETAILS_FORM_EMPTY_STATE)
        self.Header:Show()

        self.draft = nil
        self.originalDraft = nil
        self.groupReset = nil

        self.Name:ClearFocus()
        self.Description.EditBox:ClearFocus()
        self.Target:ClearFocus()

        self:NotifyDraftChanged()
        return
    end

    local _, _, group = self:GetTaskLocation()
    if not group then
        self:Init(nil)
        return
    end

    local loadFields = previousTask ~= task or self.draft == nil

    if loadFields then
        self.draft = CreateDraft(task)
        self.originalDraft = CreateDraft(task)
    end

    self.groupReset = group.reset

    self:RefreshSummary()
    self.Header:Show()
    self.Summary:Show()

    self.NameLabel:Show()
    self.DescriptionLabel:Show()
    self.ResetIntervalLabel:Show()
    self.TargetLabel:Show()

    self.Name:Show()
    self.Description:Show()
    self.Target:Show()
    
    if loadFields then
        self.Name:SetText(self.draft.name)

        self.Description.EditBox:SetText(self.draft.description)
        self.Description.EditBox:SetCursorPosition(0)
        self.Description:SetVerticalScroll(0)

        self.Target:SetText(self.draft.target)
    end

    self:RefreshResetButtons()
    self:NotifyDraftChanged()
end

function TodolooTaskDetailsFormMixin:RefreshSummary()
    local info = self:GetTaskInfo()
    if not info or not info.taskRef then
        return
    end

    local task = info.taskRef

    self.Header:SetText(task.name)
    self.Summary:SetText(string.format(
        TODOLOO_L_TASK_DETAILS_FORM_SUMMARY,
        info.character,
        task.progress,
        task.target
    ))
end

function TodolooTaskDetailsFormMixin:RefreshResetButtons()
    if not self.draft then
        self.Manual:Hide()
        self.Daily:Hide()
        self.Weekly:Hide()
        return
    end

    self.Manual:Show()
    self.Daily:Show()
    self.Weekly:Show()

    local inherited = self.groupReset ~= nil
    local selectedInterval = self.groupReset or self.draft.reset

    for _, button in ipairs(self.resetButtons) do
        button:SetChecked(button.resetInterval == selectedInterval)
        button:SetEnabled(not inherited)

        button.Text:SetFontObject(inherited and "GameFontDisableSmall" or "GameFontNormalSmall")
    end
end

function TodolooTaskDetailsFormMixin:GetTaskInfo()
    return self.currentTaskInfo
end

function TodolooTaskDetailsFormMixin:GetDraft()
    if not self.draft then
        return nil
    end

    return self.draft
end

function TodolooTaskDetailsFormMixin:SetDraftChangedCallback(callback)
    self.draftChangedCallback = callback
end

function TodolooTaskDetailsFormMixin:NotifyDraftChanged()
    if self.draftChangedCallback then
        self.draftChangedCallback()
    end
end

function TodolooTaskDetailsFormMixin:HasUnsavedChanges()
    if not self.draft or not self.originalDraft then
        return false
    end

    return self.draft.name ~= self.originalDraft.name
        or self.draft.description ~= self.originalDraft.description
        or tonumber(self.draft.target) ~= tonumber(self.originalDraft.target)
        or (self.groupReset == nil and self.draft.reset ~= self.originalDraft.reset)
end

function TodolooTaskDetailsFormMixin:ResetDraft()
    local taskInfo = self:GetTaskInfo()
    if not taskInfo then
        return
    end

    self.draft = nil
    self:Init(taskInfo)
end

function TodolooTaskDetailsFormMixin:GetTaskLocation()
    local taskInfo = self:GetTaskInfo()
    if not taskInfo then
        return
    end

    local character = Todoloo.TaskManager:GetCharacter(taskInfo.character)
    if not character then
        return
    end

    for groupId, group in ipairs(character.groups) do
        for taskId, task in ipairs(group.tasks) do
            if  task == taskInfo.taskRef then
                return groupId, taskId, group
            end
        end
    end
end