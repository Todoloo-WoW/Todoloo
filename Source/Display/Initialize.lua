local function InitializeBase()
    Todoloo.Debug.Message("Initializing display")
    Todoloo.MinimapIcon.Initialize()
    
    -- OLD TASK TRACKER
    --CreateFrame("Frame", "TodolooTaskTrackerView", UIParent, "TodolooTaskTracker")

    Todoloo.ToggleView = function()
        --TODO: Show something else than just the task tracker?)
        TodolooTrackerFrame:SetShown(not TodolooTrackerFrame:IsShown())
    end

    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) then
        Todoloo.Debug.Message("Show task tracker")
        TodolooTrackerFrame:Show()
    end
end

local CORE_EVENTS = {
    "ADDON_LOADED"
}
local coreFrame = CreateFrame("Frame")

FrameUtil.RegisterFrameForEvents(coreFrame, CORE_EVENTS)
coreFrame:SetScript("OnEvent", function(self, eventName, name)
    if eventName == "ADDON_LOADED" and name == "Todoloo" then
        self:UnregisterEvent("ADDON_LOADED")
        InitializeBase()
    end
end)