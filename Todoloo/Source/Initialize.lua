local addonName, _ = ...

local Main = {};

-- We cannot be certain that the Objective Tracker exists until the next OnUpdate event
-- hence why we're creating this temp frame.
local initFrame = CreateFrame("Frame");

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

    -- create task manager
    Todoloo.TaskManager = CreateAndInitFromMixin(TodolooTaskManagerMixin);

    Todoloo.Tasks.Initialize();

    -- reset all relevant groups and tasks
    Todoloo.Reset.ResetManager.PerformReset();

    -- Load appropriate task tracker based on player configuration
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) and not Todoloo.Config.Get(Todoloo.Config.Options.ATTACH_TASK_TRACKER_TO_OBJECTIVE_TRACKER) then
        TodolooFloatingTrackerFrame:Show();
    end

    -- We need to wait until next update rolls out, to be sure the Objective tracker has been initialized
    initFrame:SetScript("OnUpdate", function(self)
        if not ObjectiveTrackerManager:HasAnyModules() then
            return;
        end

        ObjectiveTrackerManager:SetModuleContainer(TodolooObjectiveTracker, ObjectiveTrackerFrame);
        self:SetScript("OnUpdate", nil);
    end);
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", Main.OnAddonLoaded, Main);
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", Main.OnPlayerEnteringWorld, Main);