local function InitializeBase()
    Todoloo.Debug.Message("Initializing addon")
    Todoloo.Config.Initialize()
    Todoloo.TaskManager.Initialize()
    Todoloo.ResetManager.Initialize()
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