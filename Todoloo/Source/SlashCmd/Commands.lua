local SLASH_COMMANDS_DEFINITIONS = {
    { commands = "tm, task-manager", description = TODOLOO_L_SLASHCMD_TASK_MANAGER_DESCRIPTION },
    { commands = "tt, task-tracker", description = TODOLOO_L_SLASHCMD_TASK_TRACKER_DESCRIPTION },
    { commands = "s, settings", description = TODOLOO_L_SLASHCMD_SETTINGS_DESCRIPTION },
    { commands = "h, help", description = TODOLOO_L_SLASHCMD_HELP }
}

function Todoloo.SlashCmd.OpenTaskManager()
    if not TodolooTaskManagerFrame:IsVisible() then
        ShowUIPanel(TodolooTaskManagerFrame);
    end
end

function Todoloo.SlashCmd.ToggleTaskTracker()
    if TodolooFloatingTrackerFrame:IsVisible() and not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
        TodolooFloatingTrackerFrame:Hide();
    else
        TodolooFloatingTrackerFrame:Show();
    end
end

function Todoloo.SlashCmd.OpenSettings()
    Todoloo.Config.Show();
end

function Todoloo.SlashCmd.Help()
    for i = 1, #SLASH_COMMANDS_DEFINITIONS do
        local definition = SLASH_COMMANDS_DEFINITIONS[i];
        Todoloo.Messenger.SlashMessage(definition.commands .. ": " .. definition.description)
    end
end