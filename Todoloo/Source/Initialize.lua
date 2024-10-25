---@class Todoloo
local Todoloo = select(2, ...);

---Initialize on ADDON_LOADED event
local function OnAddonLoaded()
    Todoloo.Config.Initialize();

    Todoloo.SlashCmd.Init();
end

---Initialize on PLAYER_ENTERING_WORLD event
local function OnPlayerEnteringWorld()
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

local CORE_EVENTS = {
    "ADDON_LOADED",
    "PLAYER_ENTERING_WORLD"
};
local coreFrame = CreateFrame("Frame");

FrameUtil.RegisterFrameForEvents(coreFrame, CORE_EVENTS);
coreFrame:SetScript("OnEvent", function(self, eventName, name)
    if eventName == "ADDON_LOADED" and name == "Todoloo" then
        self:UnregisterEvent("ADDON_LOADED");
        OnAddonLoaded();
    elseif eventName == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        OnPlayerEnteringWorld();
    end
end)