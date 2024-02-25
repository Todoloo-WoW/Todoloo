TodolooConfigBasicOptionsFrameMixin = {}

function TodolooConfigBasicOptionsFrameMixin:OnLoad()
    self:SetParent(SettingsPanel or InterfaceOptionsFrame)
    self.name = "Basic Options"
    self.parent = "Todoloo"

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

    if Settings then
        local category = Settings.GetCategory(self.parent)
        local subcategory = Settings.RegisterCanvasLayoutSubcategory(category, self, self.name)
        Settings.RegisterAddOnCategory(subcategory)
    else
        InterfaceOptions_AddCategory(self, "Todoloo")
    end
end

function TodolooConfigBasicOptionsFrameMixin:OnShow()
    Todoloo.Debug.Message("TodolooConfigBasicOptionsFrameMixin:OnShow")
    self.ShowTaskTracker:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER))
    self.ShowCompletedGroups:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS))
    self.ShowCompletedTasks:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS))
    self.ShowMinimapIcon:SetChecked(not Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON).hide)

    self.shownSettings = true
end

function TodolooConfigBasicOptionsFrameMixin:Save()
    Todoloo.Debug.Message("TodolooConfigBasicOptionsFrameMixin:Save")
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_TASK_TRACKER, self.ShowTaskTracker:GetChecked())
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS, self.ShowCompletedGroups:GetChecked())
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_COMPLETED_TASKS, self.ShowCompletedTasks:GetChecked())

    Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON).hide = not self.ShowMinimapIcon:GetChecked()
    if Todoloo.MinimapIcon then
        Todoloo.MinimapIcon.UpdateShown()
    end

    -- update tracker frame based on new settings
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
    Todoloo.Debug.Message("TodolooConfigBasicOptionsFrameMixin:Cancel")
end