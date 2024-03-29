local _, Todoloo = ...

---Initialize on ADDON_LOADED event
local function InitializeBase()
    Todoloo.Config.Initialize()
end

---Initialize on PLAYER_ENTERING_WORLD event
local function InitializeCharacter()
    -- create task manager
    Todoloo.TaskManager = CreateAndInitFromMixin(TodolooTaskManagerMixin)

    Todoloo.Tasks.Initialize()

    -- reset all relevant groups and tasks
    Todoloo.Reset.ResetManager.PerformReset()
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
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        InitializeCharacter()
    end
end)