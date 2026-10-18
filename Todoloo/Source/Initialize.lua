local addonName, _ = ...

local Main = {};

local function ShouldUseAttachedTracker()
    return Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER)
        and Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER)
end

function Todoloo.UpdateAttachedTracker()
    local container = TodolooAttachedTrackerContainer

    if not ShouldUseAttachedTracker() then
        container:Hide()
        return
    end

    container:Initialize()
    container:MarkDirty()
    container:Show()
end

function Main:OnAddonLoaded(addon)
    if addon ~= addonName then
        return;
    end

    Todoloo.Config.Initialize();

    Todoloo.SlashCmd.Init();
end

function Main:OnPlayerEnteringWorld(isInitialLogin, isReloadingUi)
    if not isInitialLogin and not isReloadingUi then
        return
    end

    -- Initialize task storage
    Todoloo.TaskManager = CreateAndInitFromMixin(TodolooTaskManagerMixin);

    -- Ensure migrations have run prior toresets and display initialization
    TodolooMigrationManagerMixin:Run();

    Todoloo.Tasks.Initialize();

    -- Reset all relevant groups and tasks
    Todoloo.Reset.ResetManager.PerformReset();

    -- Load appropriate task tracker based on player configuration
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) and not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
        TodolooFloatingTrackerFrame:Show();
    end

    Todoloo.UpdateAttachedTracker()
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", Main.OnAddonLoaded, Main);
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", Main.OnPlayerEnteringWorld, Main);