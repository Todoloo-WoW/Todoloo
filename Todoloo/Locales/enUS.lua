TODOLOO_LOCALES.enUS = function()
    local L = {};

    -- Configurations.
    L["CONFIG_BASIC_OPTIONS_LABEL"] = "Basic Options";
    L["CONFIG_BASIC_OPTIONS_DESCRIPTION"] = "Basic options for enabling features in Todoloo.";
    L["CONFIG_GENERAL_SECTION_HEADER"] = "General";
    
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_LABEL"] = "Announce resets";
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_DESCRIPTION"] = "With this setting active, daily and weekly resets of groups and tasks will be announced in the chat.";
    L["CONFIG_ANNOUNCE_RESET_LABEL"] = "Announce daily and weekly resets og groups and tasks in chat";
    
    L["CONFIG_TASK_TRACKER_SECTION_HEADER"] = "Task Tracker";
    L["CONFIG_SHOW_TASK_TRACKER_LABEL"] = "Show task tracker";
    
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_LABEL"] = "Hide task tracker in combat";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_LABEL"] = "Hide in combat";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_DESCRIPTION"] = "Hide the task tracker in combat and automatically show the tracker again once out of combat (this setting is only relevant when using the floating task tracker).";

    L["CONFIG_ATTACH_TRACKER_LABEL"] = "Attach task tracker to objective tracker";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_LABEL"] = "Attached task tracker";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_DESCRIPTION"] = "The task tracked will be attached to Blizzard objective tracker. Be aware that the task tracker will always be the last module and displayed at the bottom. If the objective tracker is full, you will need to minimize other modules before you can see the task tracker.";

    L["CONFIG_SHOW_COMPLETED_GROUPS_LABEL"] = "Show completed groups";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_LABEL"] = "Show completed groups";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_DESCRIPTION"] = "With this setting active, groups will stay visible in the task tracker when they are completed.";

    L["CONFIG_SHOW_COMPLETED_TASKS_LABEL"] = "Show completed tasks";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_LABEL"] = "Show completed tasks";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_DESCRIPTION"] = "With this setting active, tasks will stay visible in the task tracker when they are completed.";

    L["CONFIG_ORDER_BY_COMPLETION_LABEL"] = "Move completed tasks to bottom of groups";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_LABEL"] = "Order by completion";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_DESCRIPTION"] = "With this setting active, all completed tasks will be moved to the bottom of the group within the task tracker, regardless of the predefined order in the task manager.";

    L["CONFIG_SHOW_PROGRESS_LABEL"] = "Show group progress text";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_LABEL"] = "Show progress";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_DESCRIPTION"] = "Whether to show completed vs. not completed tasks besides the group name in the task tracker.";

    L["CONFIG_MINIMAP_SECTION_HEADER"] = "Minimap Icon";

    L["CONFIG_SHOW_MINIMAP_ICON_LABEL"] = "Show minimap icon";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_LABEL"] = "Show minimap icon";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_DESCRIPTION"] = "Show/hide the icon on the minimap.";

    -- Task manager
    L["TASK_MANAGER_FRAME_HEADER"] = "Todoloo - Task management";
    L["TASK_MANAGER_BUTTON_CREATE_GROUP"] = "Create group";

    L["TASK_MANAGER_CHARACTER_ADD_NEW_GROUP"] = "Add new group";

    L["TASK_MANAGER_GROUP_RESET_INTERVAL_LABEL"] = "Reset interval";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_NONE"] = "None";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_MANUALLY"] = "Manually";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_DAILY"] = "Daily";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_WEEKLY"] = "Weekly";
    L["TASK_MANAGER_GROUP_ACTIONS_LABEL"] = "Group actions";
    L["TASK_MANAGER_GROUP_ACTIONS_ADD_NEW_TASK"] = "Add new task";
    L["TASK_MANAGER_GROUP_ACTIONS_DELETE"] = "Delete";

    L["TASK_MANAGER_TASK_RESET_INTERVAL_LABEL"] = "Reset interval";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_CONTROLLED_BY_GROUP"] = "Reset interval is controlled by the parent group";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_MANUALLY"] = "Manually";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_DAILY"] = "Daily";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_WEEKLY"] = "Weekly";
    L["TASK_MANAGER_TASK_ACTION_LABEL"] = "Task actions";
    L["TASK_MANAGER_TASK_ACTION_DELETE"] = "Delete";

    L["TASK_MANAGER_DELETE_GROUP_DIALOG_QUESTION"] = "Are you sure you want to delete"

    L["TASK_MANAGER_HELP_CREATE_GROUP_HELP"] = "Create a new group to get started with your task management!";
    L["TASK_MANAGER_HELP_FILTER_TIP"] = "Tip: Search for a specific task or group to find the item you are looking for more easily.";
    L["TASK_MANAGER_HELP_TASK_LIST_HELP"] = "This is your overview of all your current groups and tasks.\n\n[Double-Click] on groups and tasks to change the name.\n\n[Shift]+[Left-Click] on groups to collapse.\n\n[Right-Click] on groups to add tasks, set group reset interval, and delete.\n\n[Shift]+[Left-Click] on tasks to toggle completion.\n\n[Right-Click] on tasks to set reset interval and delete."

    -- Task tracker
    L["TASK_TRACKER_GROUP_COMPLETE"] = "Group tasks done";

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