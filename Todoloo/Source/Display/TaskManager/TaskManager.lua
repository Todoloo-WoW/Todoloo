-- *****************************************************************************************************
-- ***** TASK MANAGER
-- *****************************************************************************************************

TodolooTaskManagerFrameMixin = {}

function TodolooTaskManagerFrameMixin:ApplyDesiredWidth()
    local pageWidth = self.ManagementPage:GetDesiredPageWidth()

    self.currentPageWidth = pageWidth
    self:SetWidth(self.currentPageWidth)
    UpdateUIPanelPositions(self)
end

function TodolooTaskManagerFrameMixin:SetTaskManagerInfo(taskManagerInfo)
    self:Refresh(taskManagerInfo)
end

function TodolooTaskManagerFrameMixin:Refresh(taskManagerInfo)
    --TODO: This texture is not working
    self:SetPortraitToAsset("Interface\\AddOns\\Todoloo\\Images\\Logo")

    self.ManagementPage:Refresh(taskManagerInfo)
end

function TodolooTaskManagerFrameMixin:OnShow()
    PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);

    local taskManagerInfo = Todoloo.TaskManager:GetTaskManagerInfo()
    self:SetTaskManagerInfo(taskManagerInfo)
end

function TodolooTaskManagerFrameMixin:OnHide()
    PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
end