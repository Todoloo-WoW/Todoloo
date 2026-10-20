TodolooSharingDialogMixin = {}

function TodolooSharingDialogMixin:OnLoad()
    -- Backdrop configuration remains behavioral setup, while XML owns the frame hierarchy and positioning.
    self:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
            left = 8,
            right = 8,
            top = 8,
            bottom = 8
        }
    })

    table.insert(UISpecialFrames, self:GetName())

    local edit = self.ScrollFrame.EditBox
    edit:SetMaxLetters(200000)

    self.CloseButton:SetScript("OnClick", function()
        self:Hide()
    end)

    self.BottomCloseButton:SetScript("OnClick", function()
        self:Hide()
    end)

    self.ScrollFrame:SetScript("OnMouseDown", function()
        edit:SetFocus()
    end)

    edit:SetScript("OnEscapePressed", function()
        self:Hide()
    end)

    edit:SetScript("OnTextChanged", function()
        self:UpdatePreview()
    end)

    edit:SetScript("OnCursorChanged", function(_, _, y, _, height)
        self:ScrollToCursor(y, height)
    end)

    self.ImportButton:SetScript("OnClick", function()
        self:Import()
    end)
end

function TodolooSharingDialogMixin:OnHide()
    self.ScrollFrame.EditBox:ClearFocus()
end

function TodolooSharingDialogMixin:ScrollToCursor(y, height)
    local scroll = self.ScrollFrame
    local top = -y
    local current = scroll:GetVerticalScroll()
    local viewport = scroll:GetHeight()
    local target = current

    if top < current then
        target = top
    elseif top + height > current + viewport then
        target = top + height - viewport
    end

    scroll:SetVerticalScroll(math.max(0, math.min(target, scroll:GetVerticalScrollRange())))
end

function TodolooSharingDialogMixin:UpdatePreview()
    if not self.importing then
        return
    end

    local text = self.ScrollFrame.EditBox:GetText()

    self.ImportButton:Disable()

    if text == "" then
        self.Status:SetText("")
        return
    end

    local data, message = Todoloo.Sharing.Decode(text)

    if not data then
        self.Status:SetText(message)
        return
    end

    self.Status:SetText(string.format(TODOLOO_L_SHARE_PREVIEW, #data.groups, data.taskCount))

    self.ImportButton:SetEnabled(#data.groups > 0)
end

function TodolooSharingDialogMixin:Import()
    local success, message = Todoloo.Sharing.Import(self.ScrollFrame.EditBox:GetText(), self.character)

    if success then
        self:Hide()
    else
        self.Status:SetText(message)
    end
end

function TodolooSharingDialogMixin:Initialize(character, groupId, taskId, importing)
    self.character = character
    self.importing = importing

    local title = importing and TODOLOO_L_SHARE_IMPORT or TODOLOO_L_SHARE_EXPORT

    self.Title:SetText(title .. " - " .. character)
    self.Help:SetText(importing and TODOLOO_L_SHARE_IMPORT_HELP or TODOLOO_L_SHARE_EXPORT_HELP)

    self.ImportButton:SetShown(importing)
    self.ImportButton:Disable()
    self.Status:SetText("")

    local text = ""
    local message

    if not importing then
        text, message = Todoloo.Sharing.Export(character, groupId, taskId)
    end

    self.ScrollFrame.EditBox:SetText(text or "")

    if importing then
        self:UpdatePreview()
    elseif message then
        self.Status:SetText(message)
    end
end

function Todoloo.Sharing.ShowDialog(character, groupId, taskId, importing)
    local dialog = TodolooSharingDialog

    dialog:Initialize(character, groupId, taskId, importing)
    dialog:Show()
    dialog.ScrollFrame.EditBox:SetFocus()
    dialog.ScrollFrame.EditBox:HighlightText()
end


function Todoloo.Sharing.AddMenu(character, groupId, taskId, level)
    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.text = TODOLOO_L_SHARE_EXPORT
    info.func = function()
        Todoloo.Sharing.ShowDialog(character, groupId, taskId, false)
    end

    UIDropDownMenu_AddButton(info, level)

    if not groupId then
        info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true
        info.text = TODOLOO_L_SHARE_IMPORT
        info.func = function()
            Todoloo.Sharing.ShowDialog(character, nil, nil, true)
        end

        UIDropDownMenu_AddButton(info, level)
    end

    UIDropDownMenu_AddSpace(level)
end