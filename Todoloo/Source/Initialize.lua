local Main = {};

function Main:OnAddonLoaded()
    Todoloo.Config.Initialize();

    Todoloo.SlashCmd.Init();
end

function Main:OnPlayerEnteringWorld(isInitialLogin, isReloadingUi)
    if not isInitialLogin and not isReloadingUi then
        return
    end

    -- create task manager
    Todoloo.TaskManager = CreateAndInitFromMixin(TodolooTaskManagerMixin);

    Todoloo.Tasks.Initialize();

    -- reset all relevant groups and tasks
    Todoloo.Reset.ResetManager.PerformReset();

    -- Load appropriate task tracker based on player configuration
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) and not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
        TodolooFloatingTrackerFrame:Show();
    end
    
    ObjectiveTrackerManager:SetModuleContainer(TodolooObjectiveTracker, ObjectiveTrackerFrame);
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", Main.OnAddonLoaded, Main);
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", Main.OnPlayerEnteringWorld, Main);