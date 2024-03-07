TodolooConfigBasicOptionsFrameMixin = {}

function TodolooConfigBasicOptionsFrameMixin:OnLoad()
    self:SetParent(SettingsPanel or InterfaceOptionsFrame)
    self.name = "Todoloo"

    self.cancel = function()
        self:Cancel()
    end

    self.okay = function()
        if self.shownSettings then
            self:Save()
        end
    end

    self.OnCommit = self.okay
    self.OnDefault = function() end
    self.OnRefresh = function() end

    -- add Todoloo category to addon settings
    if Settings and SettingsPanel then
        local category = Settings.RegisterCanvasLayoutCategory(self, self.name)
        category.ID = self.name
        Settings.RegisterAddOnCategory(category)
    else
        InterfaceOptions_AddCategory(self, self.name)
    end
end

function TodolooConfigBasicOptionsFrameMixin:ResetTrackerPosition()
    TodolooTrackerFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 100, -150)
end

function TodolooConfigBasicOptionsFrameMixin:OnShow()
    self.ShowTaskTracker:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER))
    self.ShowCompletedGroups:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS))
    self.ShowCompletedTasks:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS))
    self.OrderByCompletion:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.ORDER_BY_COMPLETION))
    self.ShowGroupProgressText:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT))
    self.ShowMinimapIcon:SetChecked(not Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON).hide)

    self.shownSettings = true
end

function TodolooConfigBasicOptionsFrameMixin:Save()
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_TASK_TRACKER, self.ShowTaskTracker:GetChecked())
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS, self.ShowCompletedGroups:GetChecked())
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_COMPLETED_TASKS, self.ShowCompletedTasks:GetChecked())
    Todoloo.Config.Set(Todoloo.Config.Options.ORDER_BY_COMPLETION, self.OrderByCompletion:GetChecked())
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT, self.ShowGroupProgressText:GetChecked())

    Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON).hide = not self.ShowMinimapIcon:GetChecked()
    if Todoloo.MinimapIcon then
        Todoloo.MinimapIcon.UpdateShown()
    end

    -- update tracker frame based on new settings
    --TODO: Update via event
    if TodolooTrackerFrame then
        if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) then
            TodolooTrackerFrame:Show()
        else
            TodolooTrackerFrame:Hide()
        end

        if TodolooTrackerFrame:IsVisible() then
            TodolooTracker_Update()
        end
    end
end

function TodolooConfigBasicOptionsFrameMixin:Cancel()
end