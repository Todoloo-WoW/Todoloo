local _, Todoloo = ...

Todoloo.Tasks.Events = {
    -- ***** GROUP EVENTS
    GROUP_ADDED     = "GROUP_ADDED",
    GROUP_UPDATED   = "GROUP_UPDATED",
    GROUP_REMOVED   = "GROUP_REMOVED",
    GROUP_RESET     = "GROUP_RESET",
    GROUP_MOVED     = "GROUP_MOVED",

    -- ***** TASK EVENTS
    TASK_ADDED          = "TASK_ADDED",
    TASK_UPDATED        = "TASK_UPDATED",
    TASK_REMOVED        = "TASK_REMOVED",
    TASK_COMPLETION_SET = "TASK_COMPLETION_SET",
    TASK_RESET          = "TASK_RESET",
    TASK_MOVED          = "TASK_MOVED",

    -- ***** OTHER
    TASK_LIST_UPDATE    = "TASK_LIST_UPDATE",   -- fired whenever a search within the task manager has begun
    FILTER_CHANGED      = "FILTER_CHANGED",     -- fired when filter in task manager has changed
};

Todoloo.Reset.Events = {
    RESET_PERFORMED = "RESET_PERFORMED"
};

Todoloo.Config.Events = {
    CONFIG_CHANGED = "CONFIG_CHANGED"
};