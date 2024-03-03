Todoloo.Tasks.Events = {
    -- ***** GROUP EVENTS
    GROUP_ADDED     = "GROUP_ADDED",
    GROUP_UPDATED   = "GROUP_UPDATED",
    GROUP_REMOVED   = "GROUP_REMOVED",
    GROUP_RESET     = "GROUP_RESET",

    -- ***** TASK EVENTS
    TASK_ADDED          = "TASK_ADDED",
    TASK_UPDATED        = "TASK_UPDATED",
    TASK_REMOVED        = "TASK_REMOVED",
    TASK_COMPLETION_SET = "TASK_COMPLETION_SET",
    TASK_RESET          = "TASK_RESET",
    TASK_MOVED          = "TASK_MOVED",

    -- ***** OTHER
    TASK_LIST_UPDATE = "TASK_LIST_UPDATE" -- fired whenever a search within the taskmanager has begun
}

Todoloo.Reset.Events = {
    RESET_PERFORMED = "RESET_PERFORMED"
}