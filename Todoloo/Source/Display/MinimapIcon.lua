local icon = LibStub("LibDBIcon-1.0")

---Initialize minimap icon
function Todoloo.MinimapIcon.Initialize()
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
                Todoloo.ToggleTaskManager()
            end
        end,
        OnTooltipShow = function(tip)
            tip:SetText("Todoloo")
            tip:AddLine(TODOLOO_L_MINIMAP_ICON_LEFT_CLICK .. " " .. WHITE_FONT_COLOR:WrapTextInColorCode(TODOLOO_L_MINIMAP_ICON_OPEN_TASK_MANAGER))
            tip:AddLine(TODOLOO_L_MINIMAP_ICON_RIGHT_CLICK .. " " .. WHITE_FONT_COLOR:WrapTextInColorCode(TODOLOO_L_MINIMAP_ICON_OPEN_SETTINGS))
        end
    })

    icon:Register("Todoloo", dataObj, Todoloo.Config.Get(Todoloo.Config.Options.MINIMAP_ICON))
end

function Todoloo.MinimapIcon.UpdateShown()
    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_MINIMAP_ICON) then
        icon:Show("Todoloo")
    else
        icon:Hide("Todoloo")
    end
end