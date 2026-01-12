---Valid Todoloo config options
Todoloo.Config.Options = {
    -- Task tracker settings
    SHOW_TASK_TRACKER = "show_task_tracker",
    ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER = "attach_task_tracker_to_objective_tracker",
    TASK_TRACKER_BACKGROUND_OPCAITY = "task_tracker_background_opacity",
    SHOW_COMPLETED_GROUPS = "show_completed_groups",
    SHOW_COMPLETED_TASKS = "show_completed_tasks",
    TASK_TRACKER_WIDTH = "task_tracker_width",
    TASK_TRACKER_HEIGHT = "task_tracker_height",
    ORDER_BY_COMPLETION = "order_by_completion",
    HIDE_TASK_TRACKER_IN_COMBAT = "hide_task_tracker_in_combat",
    SHOW_GROUP_PROGRESS_TEXT = "show_group_progress_text",

    -- General
    SHOW_MINIMAP_ICON = "show_minimap_icon",
    MINIMAP_ICON = "minimap_icon",
    MESSENGER = "messenger",

    -- Calculated values
    LAST_RESET_PERFORMED = "last_reset_performed",

    -- Meta settings
    SETTINGS_CONVERSION_TABLE = "settings_conversion_table"
};

---Default Todoloo config option values
Todoloo.Config.Defaults = {
    -- Task tracker settings
    [Todoloo.Config.Options.SHOW_TASK_TRACKER] = true,
    [Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER] = false,
    [Todoloo.Config.Options.TASK_TRACKER_BACKGROUND_OPCAITY] = 0,
    [Todoloo.Config.Options.SHOW_COMPLETED_GROUPS] = true,
    [Todoloo.Config.Options.SHOW_COMPLETED_TASKS] = false,
    [Todoloo.Config.Options.TASK_TRACKER_WIDTH] = "235",
    [Todoloo.Config.Options.TASK_TRACKER_HEIGHT] = "500",
    [Todoloo.Config.Options.ORDER_BY_COMPLETION] = false,
    [Todoloo.Config.Options.HIDE_TASK_TRACKER_IN_COMBAT] = false,
    [Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT] = false,

    -- General
    [Todoloo.Config.Options.SHOW_MINIMAP_ICON] = false,
    [Todoloo.Config.Options.MINIMAP_ICON] = {},
    [Todoloo.Config.Options.MESSENGER] = false,

    -- Calculated values
    [Todoloo.Config.Options.LAST_RESET_PERFORMED] = GetServerTime(),

    -- Meta settings
    [Todoloo.Config.Options.SETTINGS_CONVERSION_TABLE] = {}
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

    -- Convert from older version of the settings
    Todoloo.Config:ConvertSettingsToVersion12_0_0();
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

-- *****************************************************************************************************
-- ***** CONFIG VERSION CONVERTERS
-- *****************************************************************************************************
-- These functions allow for Todoloo to convert configurations from previous version to new version
-- in the instances where configurations have changed in a way that requires conversion between
-- old and new configuration keys.

do
    ---Check if the version conversion has already been performed
    ---@param versionId string Version identifier
    function Todoloo.Config:HasPerformedConversion(versionId)
        if TODOLOO_CONFIG[Todoloo.Config.Options.SETTINGS_CONVERSION_TABLE][versionId] then
            -- Conversion has already been performed
            return;
        end
    end

    ---Register conversion of settings for the given version identifier
    ---@param versionId string Version identifier
    function Todoloo.Config:RegisterConversion(versionId)
        table.insert(TODOLOO_CONFIG[Todoloo.Config.Options.SETTINGS_CONVERSION_TABLE], versionId);
    end

    ---Convert settings to new v12.0.0 format.
    ---Converts "minimap_icon.hide" to "show_minimap_icon"
    function Todoloo.Config:ConvertSettingsToVersion12_0_0()
        local versionId = "12_0_0";
        if Todoloo.Utils.StringArrayContains(TODOLOO_CONFIG[Todoloo.Config.Options.SETTINGS_CONVERSION_TABLE], versionId) then
            -- Conversion has already been performed
            return;
        end

        -- Convert minimap setting
        local oldMinimapSetting = TODOLOO_CONFIG[Todoloo.Config.Options.MINIMAP_ICON];
        if oldMinimapSetting.hide ~= nil then
            TODOLOO_CONFIG[Todoloo.Config.Options.SHOW_MINIMAP_ICON] = not oldMinimapSetting.hide;
            oldMinimapSetting.hide = nil;
        end

        Todoloo.Config:RegisterConversion(versionId);
    end
end