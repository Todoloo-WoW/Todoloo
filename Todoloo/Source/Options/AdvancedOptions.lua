local _, Todoloo = ...

TodolooConfigAdvancedOptionsFrameMixin = {}

function TodolooConfigAdvancedOptionsFrameMixin:OnLoad()
    self:SetParent(SettingsPanel or InterfaceOptionsFrame)
    self.name = "Advanced Options"
    self.parent = "Todoloo"

    self.cancel = function()
        self:Cancel()
    end

    self.okay = function()
        if self.shownSettings then
            self:Save()
        end
    end

    self.OnCommit = self.okay
    self.OnDefault = function() end
    self.OnRefresh = function() end

    if Settings then
        local category = Settings.GetCategory(self.parent)
        local subcategory = Settings.RegisterCanvasLayoutSubcategory(category, self, self.name)
        Settings.RegisterAddOnCategory(subcategory)
    else
        InterfaceOptions_AddCategory(self, "Todoloo")
    end
end

function TodolooConfigAdvancedOptionsFrameMixin:OnShow()
    self.DebugOutput:SetChecked(Todoloo.Config.Get(Todoloo.Config.Options.DEBUG))

    self.shownSettings = true
end

function TodolooConfigAdvancedOptionsFrameMixin:Save()
    Todoloo.Config.Set(Todoloo.Config.Options.DEBUG, self.DebugOutput:GetChecked())
end

function TodolooConfigAdvancedOptionsFrameMixin:Cancel()
end