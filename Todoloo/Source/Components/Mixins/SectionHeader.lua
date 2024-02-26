TodolooSectionHeaderMixin = {}

function TodolooSectionHeaderMixin:OnLoad()
    if self.headerText ~= nil then
        self.Header:SetText(self.headerText)
    end
end