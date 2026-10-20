TODOLOO_LOCALES.enUS = function()
    local L = {};

    -- Configurations.
    L["CONFIG_BASIC_OPTIONS_LABEL"] = "Basic Options";
    L["CONFIG_BASIC_OPTIONS_DESCRIPTION"] = "Basic options for enabling features in Todoloo.";
    L["CONFIG_GENERAL_SECTION_HEADER"] = "General";
    
    L["CONFIG_ANNOUNCE_RESET_LABEL"] = "Announce resets";
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_DESCRIPTION"] = "With this setting active, daily and weekly resets of groups and tasks will be announced in the chat.";
    
    L["CONFIG_TASK_TRACKER_SECTION_HEADER"] = "Task Tracker";
    L["CONFIG_SHOW_TASK_TRACKER_LABEL"] = "Show task tracker";
    
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_LABEL"] = "Hide task tracker in combat";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_DESCRIPTION"] = "Hide the task tracker in combat and automatically show the tracker again once out of combat (this setting is only relevant when using the floating task tracker).";

    L["CONFIG_ATTACH_TRACKER_LABEL"] = "Attach to objective tracker";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_DESCRIPTION"] = "The task tracked will be attached to Blizzard objective tracker. Be aware that the task tracker will always be the last module and displayed at the bottom. If the objective tracker is full, you will need to minimize other modules before you can see the task tracker.";

    L["CONFIG_SHOW_COMPLETED_GROUPS_LABEL"] = "Show completed groups";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_DESCRIPTION"] = "With this setting active, groups will stay visible in the task tracker when they are completed.";

    L["CONFIG_SHOW_COMPLETED_TASKS_LABEL"] = "Show completed tasks";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_DESCRIPTION"] = "With this setting active, tasks will stay visible in the task tracker when they are completed.";

    L["CONFIG_ORDER_BY_COMPLETION_LABEL"] = "Order by completion";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_DESCRIPTION"] = "With this setting active, all completed tasks will be moved to the bottom of the group within the task tracker, regardless of the predefined order in the task manager.";

    L["CONFIG_SHOW_PROGRESS_LABEL"] = "Show group progress text";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_DESCRIPTION"] = "Whether to show completed vs. not completed tasks besides the group name in the task tracker.";

    L["CONFIG_TASK_TRACKER_WIDTH_LABEL"] = "Task tracker width";
    L["CONFIG_TASK_TRACKER_WIDTH_TOOLTIP_DESCRIPTION"] = "Defines the width of the floating task tracker.";

    L["CONFIG_TASK_TRACKER_HEIGHT_LABEL"] = "Task tracker height";
    L["CONFIG_TASK_TRACKER_HEIGHT_TOOLTIP_DESCRIPTION"] = "Defines the height of the floating task tracker.";

    L["CONFIG_MINIMAP_SECTION_HEADER"] = "Minimap Icon";

    L["CONFIG_SHOW_MINIMAP_ICON_LABEL"] = "Show minimap icon";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_DESCRIPTION"] = "Show/hide the icon on the minimap.";

    -- Sharing
    L["SHARE_EXPORT"] = "Export"
    L["SHARE_IMPORT"] = "Import"
    L["SHARE_EXPORT_HELP"] = "Press Ctrl+C to copy this string and share it with another client. Only saved task settings are exported."
    L["SHARE_IMPORT_HELP"] = "Paste a Todoloo string. Import adds new groups to this character without replacing existing groups. Task progress starts at zero."
    L["SHARE_PREVIEW"] = "%d groups, %d tasks ready to import."
    L["SHARE_EXPORT_ERROR"] = "Unable to export this setup. It may exceed the sharing limits."
    L["SHARE_IMPORT_ERROR"] = "Invalid, incomplete, unsupported, or oversized Todoloo string."

    -- Task manager
    L["TASK_MANAGER_FRAME_HEADER"] = "Todoloo - Task management";
    L["TASK_MANAGER_BUTTON_CREATE_GROUP"] = "Create group";

    L["TASK_MANAGER_CHARACTER_ADD_NEW_GROUP"] = "Add new group";

    L["TASK_MANAGER_DEFAULT_GROUP_NAME"] = "New group";
    L["TASK_MANAGER_DEFAULT_TASK_NAME"] = "New task";

    L["TASK_MANAGER_NO_RESULTS"] = "No results";

    L["TASK_MANAGER_GROUP_RESET_INTERVAL_LABEL"] = "Reset interval";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_NONE"] = "None";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_MANUALLY"] = "Manually";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_DAILY"] = "Daily";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_WEEKLY"] = "Weekly";
    L["TASK_MANAGER_GROUP_ACTIONS_LABEL"] = "Group actions";
    L["TASK_MANAGER_GROUP_ACTIONS_ADD_NEW_TASK"] = "Add new task";
    L["TASK_MANAGER_GROUP_ACTIONS_DELETE"] = "Delete";
    L["TASK_MANAGER_GROUP_DELETE_CONFIRMATION"] = "Are you sure you want to delete '%s'?";

    L["TASK_MANAGER_TASK_RESET_INTERVAL_LABEL"] = "Reset interval";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_CONTROLLED_BY_GROUP"] = "Reset interval is controlled by the parent group";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_MANUALLY"] = "Manually";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_DAILY"] = "Daily";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_WEEKLY"] = "Weekly";
    L["TASK_MANAGER_TASK_ACTION_LABEL"] = "Task actions";
    L["TASK_MANAGER_TASK_ACTION_DELETE"] = "Delete";

    -- TASK_MANAGER_DELETE_GROUP_DIALOG_QUESTION IS DEPRECATED
    L["TASK_MANAGER_DELETE_GROUP_DIALOG_QUESTION"] = "Are you sure you want to delete"

    L["TASK_MANAGER_HELP_CREATE_GROUP_HELP"] = "Create a new group to get started with your task management!";
    L["TASK_MANAGER_HELP_FILTERS"] = "Search for tasks or groups by name. Use the filter menu to choose which characters appear."
    L["TASK_MANAGER_HELP_TASK_LIST_INTERACTIONS"] = "Select a task to open its editor.\n\n"
        .. "[Double-Click] a group to rename it. [Shift-Click] a group to collapse or expand it. [Click] a character header to collapse or expand that character.\n\n"
        .. "[Right-Click] a group to add tasks, change its reset interval, or delete it. [Right-Click] a task to delete it.\n\n"
        .. "[Shift-Click] a task to add progress. [Ctrl-Click] to subtract progress."
    L["TASK_MANAGER_HELP_TASK_DETAILS"] = "Edit the selected task's title, description, reset interval, and repetition count here.\n\n"
        .. "When the parent group defines a reset interval, the task inherits it and its reset controls are disabled."
    L["TASK_MANAGER_HELP_SAVE_RESET"] = "Save applies your changes to the selected task. Reset restores its saved settings."
    L["TASK_MANAGER_HELP_SHARING"] = "Share tasks, groups, or a complete character setup with your friends!\n\n"
        .. "[Right-Click] a character, group, or task and choose Export. "
        .. "Press Ctrl+C to copy the string.\n\n"
        .. "Click Import to paste a string for your current character, or "
        .. "[Right-Click] another character and choose Import.\n\n"
        .. "Imported groups are added alongside existing groups. "
        .. "Task progress starts at zero."

    -- Task details form
    L["TASK_DETAILS_FORM_SUMMARY"] = "%s\nProgress: %d/%d";
    L["TASK_DETAILS_FORM_EMPTY_STATE"] = "Select or create a task to get started.";
    L["TASK_DETAILS_FORM_TITLE_LABEL"] = "Title";
    L["TASK_DETAILS_FORM_DESCRIPTION_LABEL"] = "Description";
    L["TASK_DETAILS_FORM_DESCRIPTION_PLACEHOLDER"] = "Custom task description (optional)";
    L["TASK_DETAILS_FORM_RESET_INTERVAL_LABEL"] = "Reset Interval";
    L["TASK_DETAILS_FORM_RESET_INTERVAL_MANUALLY"] = "Manually";
    L["TASK_DETAILS_FORM_RESET_INTERVAL_DAILY"] = "Daily";
    L["TASK_DETAILS_FORM_RESET_INTERVAL_WEEKLY"] = "Weekly";
    L["TASK_DETAILS_FORM_TARGET_REPITITION_LABEL"] = "Repetition count";
    L["TASK_DETAILS_FORM_LOOT_ITEM_LABEL"] = "Attached items";
    L["TASK_DETAILS_FORM_LOOT_ITEM_HELP"] = "Enter an item ID to attach it. Looting any attached item advances this task.";
    L["TASK_DETAILS_FORM_LOOT_ITEM_ADD"] = "Add";
    L["TASK_DETAILS_FORM_LOOT_ITEM_REMOVE"] = "Remove";
    L["TASK_DETAILS_FORM_LOOT_ITEM_DUPLICATE"] = "This item is already attached.";
    L["TASK_DETAILS_FORM_LOOT_ITEM_UNKNOWN"] = "Item %d";
    L["TASK_DETAILS_FORM_LOOT_ITEM_NONE"] = "No item attached";
    L["TASK_DETAILS_FORM_LOOT_ITEM_INVALID"] = "Enter a valid item ID, or leave empty.";
    L["TASK_DETAILS_FORM_LOOT_ITEM_LOADING"] = "Loading item...";
    L["TASK_DETAILS_FORM_LOOT_ITEM_UNAVAILABLE"] = "Item information could not be loaded.";
    L["TASK_DETAILS_FORM_SAVE_BUTTON_LABEL"] = "Save";
    L["TASK_DETAILS_FORM_RESET_BUTTON_LABEL"] = "Reset";
    L["TASK_DETAILS_UNSAVED_CHANGES_DIALOG_DESCRIPTION"] = "This task has unsaved changes. Continue without saving?";
    L["TASK_DETAILS_UNSAVED_CHANGES_DIALOG_CONFIRM_BUTTON"] = "Discard changes";
    L["TASK_DETAILS_FORM_ERROR_TITLE_REQUIRED"] = "Enter a title for the task.";
    L["TASK_DETAILS_FORM_ERROR_TARGET_INVALID"] = "Repetition count must be a whole number of at least 1.";

    -- Task tracker
    L["TASK_TRACKER_GROUP_COMPLETE"] = "Group tasks done";
    L["TASK_TRACKER_MORE_TASKS"] = "Additional tasks hidden";
    L["TASK_TRACKER_EDIT_MODE_HEIGHT"] = "Height";
    L["TASK_TRACKER_EDIT_MODE_TEXT_SIZE"] = "Text Size";

    -- Reset manager
    L["RESET_MANAGER_GROUP"] = "Group";
    L["RESET_MANAGER_TASK"] = "Task";
    L["RESET_MANAGER_ON"] = "on";
    L["RESET_MANAGER_HAS_BEEN_RESET"] = "has been reset";

    -- Task filter
    L["TASK_FILTER_CHECK_ALL"] = "Check all";
    L["TASK_FILTER_UNCHECK_ALL"] = "Uncheck all";

    -- Minimap icon
    L["MINIMAP_ICON_LEFT_CLICK"] = "Left-Click:";
    L["MINIMAP_ICON_RIGHT_CLICK"] = "Right-Click:";
    L["MINIMAP_ICON_OPEN_TASK_MANAGER"] = "Open task manager";
    L["MINIMAP_ICON_OPEN_SETTINGS"] = "Open settings";

    -- Slash commands.
    L["SLASHCMD_UNKNOWN_COMMAND"] = "Unknown command";
    L["SLASHCMD_TASK_MANAGER_DESCRIPTION"] = "Open the task manager.";
    L["SLASHCMD_TASK_TRACKER_DESCRIPTION"] = "Toggle the floating task tracker.";
    L["SLASHCMD_SETTINGS_DESCRIPTION"] = "Open Todoloo settings.";
    L["SLASHCMD_HELP"] = "Show this help message.";

    return L;
end