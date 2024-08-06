local _, Todoloo = ...

TodolooConfigBasicOptionsFrameMixin = {};

function TodolooConfigBasicOptionsFrameMixin:OnLoad()
    Todoloo.EventBus:RegisterSource(self, "basic_options");
    
    self:SetParent(SettingsPanel or InterfaceOptionsFrame);
    self.name = "Todoloo";

    self.cancel = function()
        self:Cancel();
    end

    self.okay = function()
        if self.shownSettings then
            self:Save();
        end
    end

    self.OnCommit = self.okay;
    self.OnDefault = function() end
    self.OnRefresh = function() end

    -- add Todoloo category to addon settings
    if Settings and SettingsPanel then
        local category = Settings.RegisterCanvasLayoutCategory(self, self.name);
        category.ID = self.name;
        Settings.RegisterAddOnCategory(category);
    else
        InterfaceOptions_AddCategory(self, self.name);
    end
end

function TodolooConfigBasicOptionsFrameMixin:ResetTrackerPosition()
    TodolooFloatingTrackerFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 100, -150);
end

function TodolooConfigBasicOptionsFrameMixin:OnShow()
    self.ShowTaskTracker:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER));
    self.AttachTaskTrackerToObjectiveTracker:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER));
    self.ShowCompletedGroups:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS));
    self.ShowCompletedTasks:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS));
    self.OrderByCompletion:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.ORDER_BY_COMPLETION));
    self.ShowGroupProgressText:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT));
    self.ShowMinimapIcon:SetChecked(not Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON).hide);

    self.shownSettings = true;
end

function TodolooConfigBasicOptionsFrameMixin:Save()
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_TASK_TRACKER, self.ShowTaskTracker:GetChecked());
    Todoloo.Config.Set(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER, self.AttachTaskTrackerToObjectiveTracker:GetChecked());
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_COMPLETED_GROUPS, self.ShowCompletedGroups:GetChecked());
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_COMPLETED_TASKS, self.ShowCompletedTasks:GetChecked());
    Todoloo.Config.Set(Todoloo.Config.Options.ORDER_BY_COMPLETION, self.OrderByCompletion:GetChecked());
    Todoloo.Config.Set(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT, self.ShowGroupProgressText:GetChecked());

    Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON).hide = not self.ShowMinimapIcon:GetChecked();
    if Todoloo.MinimapIcon then
        Todoloo.MinimapIcon.UpdateShown();
    end

    Todoloo.EventBus:TriggerEvent(self, Todoloo.Config.Events.CONFIG_CHANGED);

    if TodolooFloatingTrackerFrame then
        if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) and not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
            TodolooFloatingTrackerFrame:Show();
        else
            TodolooFloatingTrackerFrame:Hide();
        end
    end
end

function TodolooConfigBasicOptionsFrameMixin:Cancel()
end