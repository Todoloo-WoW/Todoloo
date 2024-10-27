-- *****************************************************************************************************
-- ***** TASK MANAGER
-- *****************************************************************************************************

TodolooTaskManagerFrameMixin = {}

function TodolooTaskManagerFrameMixin:OnLoad()
    self:SetPortraitTextureRaw([[Interface\AddOns\Todoloo\Images\Logo]])
end

function TodolooTaskManagerFrameMixin:ApplyDesiredWidth()
    local pageWidth = self.ManagementPage:GetDesiredPageWidth()

    self.currentPageWidth = pageWidth
    self:SetWidth(self.currentPageWidth)
    UpdateUIPanelPositions(self)
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