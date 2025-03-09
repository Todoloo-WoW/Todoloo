function Todoloo.SlashCmd.Init()
    SlashCmdList["Todoloo"] = Todoloo.SlashCmd.Handler
    SLASH_Todoloo1 = "/todoloo";
    SLASH_Todoloo2 = "/tdl";
end

local SLASH_COMMANDS = {
    ["tm"] = Todoloo.SlashCmd.OpenTaskManager,
    ["task-manager"] = Todoloo.SlashCmd.OpenTaskManager,
    ["tt"] = Todoloo.SlashCmd.ToggleTaskTracker,
    ["task-tracker"] = Todoloo.SlashCmd.ToggleTaskTracker,
    ["s"] = Todoloo.SlashCmd.OpenSettings,
    ["settings"] = Todoloo.SlashCmd.OpenSettings,
    ["h"] = Todoloo.SlashCmd.Help,
    ["help"] = Todoloo.SlashCmd.Help
}

function Todoloo.SlashCmd.Handler(input)
    if #input == 0 then
        Todoloo.SlashCmd.Help();
    else
        local command = Todoloo.Utils.SplitCommand(input);
        local handler = SLASH_COMMANDS[command[1]];
        if handler == nil then
            Todoloo.Messenger.SlashMessage(TODOLOO_L_SLASHCMD_UNKNOWN_COMMAND .. " '" .. command[1] .. "'");
            Todoloo.SlashCmd.Help();
        else
            handler(unpack(Todoloo.Utils.Slice(command, 2, #command-1)));
        end
    end
end