---@class Todoloo
local Todoloo = select(2, ...);

local function OnAddonLoaded()
    Todoloo.MinimapIcon.Initialize();

    -- toggle task management frame
    Todoloo.ToggleTaskManager = function()
        if TodolooTaskManagerFrame:IsVisible() then
            HideUIPanel(TodolooTaskManagerFrame);
        else
            ShowUIPanel(TodolooTaskManagerFrame);
        end
    end

    local attributes = 
    {
        area = "left",
        xoffset = 35,
        pushable = 1,
        allowOtherPanels = 1,
        checkFit = 1
    };
    RegisterUIPanel(TodolooTaskManagerFrame, attributes);
end

local function OnPlayerEnteringWorld()
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
        OnPlayerEnteringWorld();
    end
end)