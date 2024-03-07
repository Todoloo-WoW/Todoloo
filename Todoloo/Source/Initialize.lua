---Initialize on ADDON_LOADED event.
local function InitializeBase()
    Todoloo.Config.Initialize()
end

---Initialize on PLAYER_ENTERING_WORLD event.
---Initialize all thing that require access to the character.
local function InitializeCharacter()
    -- create task manager
    Todoloo.TaskManager = CreateAndInitFromMixin(TodolooTaskManagerMixin)

    -- reset all relevant tasks
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