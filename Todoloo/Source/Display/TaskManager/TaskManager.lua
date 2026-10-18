TodolooTaskManagerFrameMixin = {}

function TodolooTaskManagerFrameMixin:OnLoad()
    self:SetPortraitTextureRaw([[Interface\AddOns\Todoloo\Images\Logo]])

    self.CloseButton:SetScript("OnClick", function()
        self:RequestClose()
    end)
end

function TodolooTaskManagerFrameMixin:Refresh(taskManagerInfo)
    self.ManagementPage:Refresh(taskManagerInfo)
end

function TodolooTaskManagerFrameMixin:OnShow()
    PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);

    self:Refresh({})
end

function TodolooTaskManagerFrameMixin:OnHide()
    PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
end

function TodolooTaskManagerFrameMixin:RequestClose()
    self.ManagementPage:ConfirmDiscardChanges(function()
        HideUIPanel(self)
    end)
end