local function InitializeBase()
    Todoloo.MinimapIcon.Initialize()

    -- toggle task tracker frame
    Todoloo.ToggleTracker = function()
        --TODO: Show something else than just the task tracker?)
        TodolooTrackerFrame:SetShown(not TodolooTrackerFrame:IsShown())
    end

    -- toggle task management frame
    Todoloo.ToggleTaskManager = function()
        if TodolooTaskManagerFrame:IsVisible() then
            HideUIPanel(TodolooTaskManagerFrame)
        else
            ShowUIPanel(TodolooTaskManagerFrame)
        end
    end

    local attributes = 
    {
        area = "left",
        xoffset = 35,
        pushable = 1,
        allowOtherPanels = 1,
        checkFit = 1
    }
    RegisterUIPanel(TodolooTaskManagerFrame, attributes)
end

local function InitializeCharacter()
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_TASK_TRACKER) then
        Todoloo.Debug.Message("Show task tracker")
        TodolooTrackerFrame:Show()
    end
end

local CORE_EVENTS = {
    "ADDON_LOADED",
    "PLAYER_ENTERING_WORLD"
}
local coreFrame = CreateFrame("Frame")

FrameUtil.RegisterFrameForEvents(coreFrame, CORE_EVENTS)
coreFrame:SetScript("OnEvent", function(self, eventName, name)
    if eventName == "ADDON_LOADED" and name == "Todoloo" then
        self:UnregisterEvent("ADDON_LOADED")
        InitializeBase()
    elseif eventName == "PLAYER_ENTERING_WORLD" then
        InitializeCharacter()
    end
end)