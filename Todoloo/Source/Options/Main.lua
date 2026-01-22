function Todoloo.Config.Show()
    Settings.OpenToCategory(Todoloo.Config.Category:GetID());
end

EventUtil.ContinueOnAddOnLoaded("Todoloo", function()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Todoloo");
    Todoloo.Config.Category = category;

    -- Basic options section
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(TODOLOO_L_CONFIG_BASIC_OPTIONS_LABEL, TODOLOO_L_CONFIG_BASIC_OPTIONS_DESCRIPTION));

    do
        -- Announce resets
        local setting = Settings.RegisterAddOnSetting(
            category,
            "MESSENGER",
            Todoloo.Config.Options.MESSENGER,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_ANNOUNCE_RESET_LABEL,
            Settings.Default.False
        );

        Settings.CreateCheckbox( category, setting, TODOLOO_L_CONFIG_ANNOUNCE_RESET_TOOLTIP_DESCRIPTION);
    end

    -- Task tracker section
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(TODOLOO_L_CONFIG_TASK_TRACKER_SECTION_HEADER));

    do
        -- Show task tracker
        local setting = Settings.RegisterAddOnSetting(
            category,
            "SHOW_TASK_TRACKER",
            Todoloo.Config.Options.SHOW_TASK_TRACKER,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_SHOW_TASK_TRACKER_LABEL,
            Settings.Default.True
        );
        
        Settings.CreateCheckbox(category, setting);

        setting:SetValueChangedCallback(function(setting, value)
            if not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
                if value then
                    TodolooFloatingTrackerFrame:Show();
                else
                    TodolooFloatingTrackerFrame:Hide();
                end
            else
                TodolooFloatingTrackerFrame:Hide();
            end

            ObjectiveTrackerManager:UpdateModule(TodolooObjectiveTracker);
        end);
    end

    do
        -- Hide task tracker in combat
        local setting = Settings.RegisterAddOnSetting(
            category,
            "HIDE_TASK_TRACKER_IN_COMBAT",
            Todoloo.Config.Options.HIDE_TASK_TRACKER_IN_COMBAT,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_HIDE_TRACKER_IN_COMBAT_LABEL,
            Settings.Default.False
        );

        Settings.CreateCheckbox(category, setting, TODOLOO_L_CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_DESCRIPTION);
    end

    do
        -- Attach to objectives tracker
        local setting = Settings.RegisterAddOnSetting(
            category,
            "ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER",
            Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_ATTACH_TRACKER_LABEL,
            Settings.Default.False
        );

        Settings.CreateCheckbox(category, setting, TODOLOO_L_CONFIG_ATTACH_TRACKER_TOOLTIP_DESCRIPTION);

        setting:SetValueChangedCallback(function(setting, value)
            if value then 
                TodolooFloatingTrackerFrame:Hide();
            elseif Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) then
                TodolooFloatingTrackerFrame:Show();
            end

            ObjectiveTrackerManager:UpdateModule(TodolooObjectiveTracker);
        end);
    end

    do
        -- Show completed groups
        local setting = Settings.RegisterAddOnSetting(
            category,
            "SHOW_COMPLETED_GROUPS",
            Todoloo.Config.Options.SHOW_COMPLETED_GROUPS,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_SHOW_COMPLETED_GROUPS_LABEL,
            Settings.Default.True
        );

        Settings.CreateCheckbox(category, setting, TODOLOO_L_CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_DESCRIPTION);

        setting:SetValueChangedCallback(function(setting, value)
            TodolooTracker_Update();
            ObjectiveTrackerManager:UpdateModule(TodolooObjectiveTracker);
        end);
    end

    do
        -- Show completed tasks
        local setting = Settings.RegisterAddOnSetting(
            category,
            "SHOW_COMPLETED_TASKS",
            Todoloo.Config.Options.SHOW_COMPLETED_TASKS,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_SHOW_COMPLETED_TASKS_LABEL,
            Settings.Default.False
        );

        Settings.CreateCheckbox(category, setting, TODOLOO_L_CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_DESCRIPTION);

        setting:SetValueChangedCallback(function(setting, value)
            TodolooTracker_Update();
            ObjectiveTrackerManager:UpdateModule(TodolooObjectiveTracker);
        end);
    end

    do
        -- Move completed tasks to bottom of group
        local setting = Settings.RegisterAddOnSetting(
            category,
            "ORDER_BY_COMPLETION",
            Todoloo.Config.Options.ORDER_BY_COMPLETION,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_ORDER_BY_COMPLETION_LABEL,
            Settings.Default.False
        );

        Settings.CreateCheckbox(category, setting, TODOLOO_L_CONFIG_ORDER_BY_COMPLETION_TOOLTIP_DESCRIPTION);

        setting:SetValueChangedCallback(function(setting, value)
            TodolooTracker_Update();
            ObjectiveTrackerManager:UpdateModule(TodolooObjectiveTracker);
        end);
    end

    do
        -- Move completed tasks to bottom of group
        local setting = Settings.RegisterAddOnSetting(
            category,
            "SHOW_GROUP_PROGRESS_TEXT",
            Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_SHOW_PROGRESS_LABEL,
            Settings.Default.False
        );

        Settings.CreateCheckbox(category, setting, TODOLOO_L_CONFIG_SHOW_PROGRESS_TOOLTIP_DESCRIPTION);

        setting:SetValueChangedCallback(function(setting, value)
            TodolooTracker_Update();
            ObjectiveTrackerManager:UpdateModule(TodolooObjectiveTracker);
        end);
    end

    -- Minimap icon section
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(TODOLOO_L_CONFIG_MINIMAP_SECTION_HEADER));

    do
        -- Show minimap icon
        local setting = Settings.RegisterAddOnSetting(
            category,
            "SHOW_MINIMAP_ICON",
            Todoloo.Config.Options.SHOW_MINIMAP_ICON,
            TODOLOO_CONFIG,
            Settings.VarType.Boolean,
            TODOLOO_L_CONFIG_SHOW_MINIMAP_ICON_LABEL,
            Settings.Default.True
        );

        Settings.CreateCheckbox(category, setting, TODOLOO_L_CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_DESCRIPTION);

        setting:SetValueChangedCallback(function(setting, value)
            Todoloo.MinimapIcon.UpdateShown();
	    end);
    end

    Settings.RegisterAddOnCategory(category);
end);