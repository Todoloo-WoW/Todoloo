TodolooConfigCheckboxMixin = {}

function TodolooConfigCheckboxMixin:OnLoad()
    if self.labelText then
        self.Checkbox.Label:SetText(self.labelText)
    end
end

function TodolooConfigCheckboxMixin:SetChecked(value)
    self.Checkbox:SetChecked(value)
end

function TodolooConfigCheckboxMixin:OnMouseUp()
    self.Checkbox:Click()
end

function TodolooConfigCheckboxMixin:OnEnter()
    self.Checkbox:LockHighlight()
  end
  
function TodolooConfigCheckboxMixin:OnLeave()
    self.Checkbox:UnlockHighlight()
end

function TodolooConfigCheckboxMixin:GetChecked()
    return self.Checkbox:GetChecked()
end