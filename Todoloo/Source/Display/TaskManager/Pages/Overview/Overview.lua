-- *****************************************************************************************************
-- ***** OVERVIEW PAGE
-- *****************************************************************************************************
--TODO: Move to /Pages
TodolooOverviewPageMixin = {}

function TodolooOverviewPageMixin:OnLoad()

end

function TodolooOverviewPageMixin:Refresh()

end

function TodolooOverviewPageMixin:OnShow()
    self:SetTitle()
end

function TodolooOverviewPageMixin:SetTitle()
    local taskManagementFrame = self:GetParent()
    taskManagementFrame:SetTitle("Todoloo - Overview")
end