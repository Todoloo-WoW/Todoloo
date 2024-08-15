---@class Todoloo
local Todoloo = select(2, ...);

---Valid Todoloo config options
Todoloo.Config.Options = {
    -- ***** TASK TRACKER SETTINGS
    SHOW_TASK_TRACKER = "show_task_tracker",
    ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER = "attach_task_tracker_to_objective_tracker",
    TASK_TRACKER_BACKGROUND_OPCAITY = "task_tracker_background_opacity",
    SHOW_COMPLETED_GROUPS = "show_completed_groups",
    SHOW_COMPLETED_TASKS = "show_completed_tasks",
    TASK_TRACKER_WIDTH = "task_tracker_width",
    TASK_TRACKER_HEIGHT = "task_tracker_height",
    ORDER_BY_COMPLETION = "order_by_completion",

    -- ***** BASIC SETTINGS
    MINIMAP_ICON = "minimap_icon",
    SHOW_GROUP_PROGRESS_TEXT = "show_group_progress_text",

    -- ***** ADVANCED SETTINGS
    DEBUG = "debug",

    -- ***** CALCULATED VALUES
    LAST_RESET_PERFORMED = "last_reset_performed"
};

---Default Todoloo config option values
Todoloo.Config.Defaults = {
    [Todoloo.Config.Options.SHOW_TASK_TRACKER] = true,
    [Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER] = false,
    [Todoloo.Config.Options.TASK_TRACKER_BACKGROUND_OPCAITY] = 0,
    [Todoloo.Config.Options.SHOW_COMPLETED_GROUPS] = true,
    [Todoloo.Config.Options.SHOW_COMPLETED_TASKS] = false,
    [Todoloo.Config.Options.TASK_TRACKER_WIDTH] = "235",
    [Todoloo.Config.Options.TASK_TRACKER_HEIGHT] = "500",
    [Todoloo.Config.Options.ORDER_BY_COMPLETION] = false,

    [Todoloo.Config.Options.MINIMAP_ICON] = { hide = false },
    [Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT] = false,

    [Todoloo.Config.Options.DEBUG] = false,

    [Todoloo.Config.Options.LAST_RESET_PERFORMED] = GetServerTime()
};

-- *****************************************************************************************************
-- ***** INITIALIZATION
-- *****************************************************************************************************

---Reset all Todoloo config values to default
function Todoloo.Config.Reset()
    TODOLOO_CONFIG = {}
    for option, value in pairs(Todoloo.Config.Defaults) do
        TODOLOO_CONFIG[option] = value;
    end
end

---Initialize Todoloo config
function Todoloo.Config.Initialize()
    if TODOLOO_CONFIG == nil then
        Todoloo.Config.Reset();
    else
        for option, value in pairs(Todoloo.Config.Defaults) do
            if TODOLOO_CONFIG[option] == nil then
                TODOLOO_CONFIG[option] = value;
            end
        end
    end
end

-- *****************************************************************************************************
-- ***** FUNCTIONS
-- *****************************************************************************************************

---Is the given option a valid config option?
---@param name string Option
---@return boolean
function Todoloo.Config.IsValidOption(name)
    for _, option in pairs(Todoloo.Config.Options) do
        if option == name then
            return true;
        end
    end

    return false;
end

---Get config option value
---@param name string Config options
---@return any # Config value
function Todoloo.Config.Get(name)
    if TODOLOO_CONFIG == nil  then
        return Todoloo.Config.Default[name];
    elseif not Todoloo.Config.IsValidOption(name) then
        error("Invalid option");
    else
        return TODOLOO_CONFIG[name];
    end
end

---Set config option value
---@param name string Config option
---@param value any Config option value
function Todoloo.Config.Set(name, value)
    if TODOLOO_CONFIG == nil  then
        error("TODOLOO_CONFIG not initialized");
    elseif not Todoloo.Config.IsValidOption(name) then
        error("Invalid option");
    else
        TODOLOO_CONFIG[name] = value;
    end
end