TODOLOO_DROPDOWN_LABEL_MARGIN = 5

TodolooDropDownMixin = {}

function TodolooDropDownMixin:OnLoad()
    self.width = 0
    self.value = nil

    -- set potential label text
    if self.labelText then
        self.Label:SetText(self.labelText)
        self.width = self.Label:GetWidth() + TODOLOO_DROPDOWN_LABEL_MARGIN
    end

    -- initialize dropdown
    self.DropDownMenu:Initialize(self.optionLabels, self.optionValues, function (newValue) self:OnValueChanged(newValue) end)

    -- calculate and set correct width
    self.width = self.width + self.DropDownMenu:GetWidth()
    self:SetWidth(self.width)
end

function TodolooDropDownMixin:RegisterValueChangedCallback(func)
    self.valueChangedCallback = func
end

function TodolooDropDownMixin:SetValue(...)
    self.DropDownMenu:SetValue(...)
end

function TodolooDropDownMixin:GetValue(...)
    return self.value
end

function TodolooDropDownMixin:OnValueChanged(newValue)
    self.value = newValue
    if self.valueChangedCallback then
        self.valueChangedCallback(self)
    end
end

TodolooDropDownInternalMixin = {}

---Initialize internal dropdown
---@param labels string Comma-separated list of strings
---@param values string Comma-separated list of string
---@param clickCallback function Function to call on value changed
function TodolooDropDownInternalMixin:Initialize(labels, values, clickCallback)
    self.labels = Todoloo.Utils.SplitStringArray(labels)
    self.values = Todoloo.Utils.SplitStringArray(values)
    self.clickCallback = clickCallback

    UIDropDownMenu_Initialize(self, self.InternalInitialize)
end

function TodolooDropDownInternalMixin:InternalInitialize()
    local info = UIDropDownMenu_CreateInfo()
    
    -- add options
    for i = 1, #self.values do
        info.text = self.labels[i]
        info.value = self.values[i]
        info.func = function(entry)
            self:SetValue(entry.value)
        end
        if self.selectedValue == info.value then
            info.checked = 1
        else
            info.checked = nil
        end

        UIDropDownMenu_AddButton(info)
    end
end

---Set the selected value
---@param newValue reset
function TodolooDropDownInternalMixin:SetValue(newValue)
    local strValue = tostring(newValue)
    for index, value in ipairs(self.values) do
        if strValue == value then
            UIDropDownMenu_SetText(self, self.labels[index])
            break
        end
    end

    self.selectedValue = tonumber(newValue)
    self.clickCallback(self.selectedValue)
end