Todoloo.Config.Options = {
    SHOW_TASK_TRACKER = "show_task_tracker",
    TASK_TRACKER_BACKGROUND_OPCAITY = "task_tracker_background_opacity",
    SHOW_COMPLETED_GROUPS = "show_completed_groups",
    SHOW_COMPLETED_TASKS = "show_completed_tasks",
    TASK_TRACKER_WIDTH = "task_tracker_width",
    TASK_TRACKER_HEIGHT = "task_tracker_height",

    DEBUG = "debug",
    MINIMAP_ICON = "minimap_icon",

    FIRST_TIME_STARTUP_INITIALIZED = "first_time_startup_initialized"
}

Todoloo.Config.Defaults = {
    [Todoloo.Config.Options.SHOW_TASK_TRACKER] = true,
    [Todoloo.Config.Options.TASK_TRACKER_BACKGROUND_OPCAITY] = 0,
    [Todoloo.Config.Options.SHOW_COMPLETED_GROUPS] = true,
    [Todoloo.Config.Options.SHOW_COMPLETED_TASKS] = false,
    [Todoloo.Config.Options.TASK_TRACKER_WIDTH] = "235",
    [Todoloo.Config.Options.TASK_TRACKER_HEIGHT] = "500",

    [Todoloo.Config.Options.DEBUG] = false,
    [Todoloo.Config.Options.MINIMAP_ICON] = { hide = false },

    [Todoloo.Config.Options.FIRST_TIME_STARTUP_INITIALIZED] = false
}

function Todoloo.Config.Reset()
    Todoloo.Debug.Message("Resetting config")
    TODOLOO_CONFIG = {}
    for option, value in pairs(Todoloo.Config.Defaults) do
        TODOLOO_CONFIG[option] = value
    end
end

function Todoloo.Config.Initialize()
    Todoloo.Debug.Message("Initializing config")
    if TODOLOO_CONFIG == nil then
        Todoloo.Config.Reset()
    else
        for option, value in pairs(Todoloo.Config.Defaults) do
            if TODOLOO_CONFIG[option] == nil then
                TODOLOO_CONFIG[option] = value
            end
        end
    end
end

function Todoloo.Config.IsValidOption(name)
    for _, option in pairs(Todoloo.Config.Options) do
        if option == name then
            return true
        end
    end

    return false
end

function Todoloo.Config.Get(name)
    if TODOLOO_CONFIG == nil  then
        return Todoloo.Config.Default[name]
    else
        return TODOLOO_CONFIG[name]
    end
end

function Todoloo.Config.Set(name, value)
    if TODOLOO_CONFIG == nil  then
        error("TODOLOO_CONFIG not initialized")
    elseif not Todoloo.Config.IsValidOption(name) then
        error("Invalid option '" ..name .. "'")
    else
        TODOLOO_CONFIG[name] = value
    end
end