local icon = LibStub("LibDBIcon-1.0")

---Initialize minimap icon
function Todoloo.MinimapIcon.Initialize()
    Todoloo.Debug.Message("Initializing minimap icon")
    local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
    local dataObj = ldb:NewDataObject("Todoloo", {
        type = "launcher",
        icon = "Interface\\AddOns\\Todoloo\\Images\\Logo",
        label = "Todoloo",
        tocname = "Todoloo",
        OnClick = function(clickedFrame, button)
            if button == "RightButton" then
                Todoloo.Config.Show()
            else
                Todoloo.ToggleView()
            end
        end,
        OnTooltipShow = function(tip)
            tip:SetText("Todoloo")
        end
    })

    icon:Register("Todoloo", dataObj, Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON))
end

function Todoloo.MinimapIcon.UpdateShown()
    Todoloo.Debug.Message("Update minimap icon shown")
    if Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON).hide then
        icon:Hide("Todoloo")
    else
        icon:Show("Todoloo")
    end
end