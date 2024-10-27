local SLASH_COMMANDS_DEFINITIONS = {
    { commands = "tm, task-manager", description = "Open the task manager." },
    { commands = "tt, task-tracker", description = "Toggle the floating task tracker." },
    { commands = "s, settings", description = "Open Todoloo settings." },
    { commands = "h, help", description = "Show this help message." }
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