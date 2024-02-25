TodolooTitleFrameMixin = {}

function TodolooTitleFrameMixin:OnLoad()
    if self.titleText ~= nil then
        self.Title:SetText(self.titleText)
    end

    if self.subTitleText then
        self.SubTitle:SetText(self.subTitleText)
        self.SubTitle:SetWidth(200)
    end
end