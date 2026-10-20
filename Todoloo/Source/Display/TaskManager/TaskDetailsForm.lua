local function CreateDraft(task)
    return {
        name = task.name or "",
        description = task.description or "",
        reset = task.reset or TODOLOO_DEFAULT_RESET_INTERVAL,
        target = tostring(task.target or 1),
        lootItemIDs = CopyTable(task.lootItemIDs or {})
    }
end

local function ItemListsEqual(first, second)
    if #first ~= #second then
        return false
    end

    for index, itemID in ipairs(first) do
        if second[index] ~= itemID then
            return false
        end
    end

    return true
end

TodolooTaskDetailsFormMixin = {}

function TodolooTaskDetailsFormMixin:OnLoad()
    self.Manual.resetInterval = TODOLOO_RESET_INTERVALS.Manually
    self.Daily.resetInterval = TODOLOO_RESET_INTERVALS.Daily
    self.Weekly.resetInterval = TODOLOO_RESET_INTERVALS.Weekly

    self.resetButtons = {
        self.Manual,
        self.Daily,
        self.Weekly
    }

    for _, button in ipairs(self.resetButtons) do
        button:SetScript("OnClick", function(clickedButton)
            if self.draft and self.groupReset == nil then
                self.draft.reset = clickedButton.resetInterval
            end

            self:RefreshResetButtons()
            self:NotifyDraftChanged()
        end)
    end

    self.Name:HookScript("OnTextChanged", function(editBox)
        if not self.draft then
            return
        end

        self.draft.name = editBox:GetText()
        self:NotifyDraftChanged()
    end)

    self.Name:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)

    self.Description.EditBox:HookScript("OnTextChanged", function(editBox)
        if not self.draft then
            return
        end

        self.draft.description = editBox:GetText()
        self:NotifyDraftChanged()
    end)

    self.Description.EditBox:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)

    -- "preview" uses a full GameTooltip.
    -- "label" shows the link's name; clicking opens Blizzard's normal UI.
    local supportedLinks = {
        item = "preview",
        mount = "preview",
        quest = "preview",
        achievement = "preview",
        spell = "preview",
        enchant = "preview",          -- Individual crafting recipes
        trade = "label",              -- Profession links
        battlepet = "label",
        worldmap = "label",
        transmogappearance = "label",
        transmogillusion = "label",
    }

    -- Accept either a complete hyperlink or the data passed to link scripts.
    local function GetSupportedLinkType(link)
        if type(link) ~= "string" then
            return nil
        end

        local linkType = link:match("|H([^:|]+):")
            or link:match("^([^:|]+):")

        if linkType and supportedLinks[linkType] then
            return linkType
        end
    end

    local function HideDescriptionTooltip(editBox)
        if GameTooltip:GetOwner() == editBox then
            GameTooltip:Hide()
        end
    end

    self.Description.EditBox:SetHyperlinksEnabled(true)

    -- Keep this guard so initialization cannot register the hook twice.
    if not self.descriptionLinkInsertionHooked then
        self.descriptionLinkInsertionHooked = true

        hooksecurefunc(ChatFrameUtil, "InsertLink", function(link)
            if not self.draft
                or not self.Description.EditBox:IsShown()
                or not self.Description.EditBox:HasFocus()
                or not GetSupportedLinkType(link)
            then
                return
            end

            self.Description.EditBox:Insert(link)
        end)
    end

    self.Description.EditBox:SetScript("OnHyperlinkEnter", function(editBox, link, text)
        HideDescriptionTooltip(editBox)

        local linkType = GetSupportedLinkType(link)
        if not linkType then
            return
        end

        GameTooltip:SetOwner(editBox, "ANCHOR_RIGHT")

        if supportedLinks[linkType] == "preview" then
            GameTooltip:SetHyperlink(link)
        else
            -- These types open specialized interfaces when clicked.
            local label = text and text:match("|h(.-)|h")
                or text
                or link

            GameTooltip:SetText(label, 1, 1, 1, 1, true)
        end

        GameTooltip:Show()
    end)

    self.Description.EditBox:SetScript("OnHyperlinkLeave", HideDescriptionTooltip)

    self.Description.EditBox:SetScript(
        "OnHyperlinkClick",
        function(editBox, link, text, button)
            if not GetSupportedLinkType(link) then
                return
            end

            HideDescriptionTooltip(editBox)
            SetItemRef(link, text, button, editBox)
        end
    )

    self.Description.EditBox:HookScript("OnHide", function(editBox)
        editBox:ClearFocus()
        HideDescriptionTooltip(editBox)
    end)

    self.Target:SetMinMaxValues(1, nil)
    self.Target:HookScript("OnHide", function(spinner)
        spinner:EndIncrement()
    end)

    self.Target:HookScript("OnTextChanged", function(editBox)
        if not self.draft then
            return
        end

        self.draft.target = editBox:GetText()
        self:NotifyDraftChanged()
    end)

    self.Target:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)

    local function UpdateLootHelpWidth(panel)
        panel.Help:SetWidth(math.max(1, panel:GetWidth() - 36))
    end

    self.LootItem:HookScript("OnSizeChanged", UpdateLootHelpWidth)
    UpdateLootHelpWidth(self.LootItem)

    self.LootItem.Input:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)

    self.LootItem.Input:SetScript("OnEnterPressed", function(editBox)
        self:AddDraftLootItem()
    end)

    self.LootItem.Input:SetScript("OnHide", function(editBox)
        editBox:ClearFocus()
    end)

    self.LootItem.Input:HookScript("OnTextChanged", function()
        if self.draft then
            self:RefreshLootItemPreview()
        end
    end)

    self.LootItem:RegisterEvent("ITEM_DATA_LOAD_RESULT")

    self.LootItem:SetScript("OnEvent", function(_, _, itemID, success)
        if itemID == self.previewLootItemID then
            if success then
                self:ShowLootItemPreview(itemID)
            else
                self:SetLootItemPreviewMessage(
                    TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_UNAVAILABLE
                )
            end
        end

        if success and self.draft then
            for _, attachedItemID in ipairs(self.draft.lootItemIDs) do
                if attachedItemID == itemID then
                    self:RefreshLootItemList()
                    break
                end
            end
        end
    end)

    self.LootItem.Add:SetScript("OnClick", function()
        self:AddDraftLootItem()
    end)

     self.LootItem.Icon:ClearAllPoints()
     self.LootItem.Icon:SetSize(20, 20)
     self.LootItem.Icon:SetPoint("TOPLEFT", self.LootItem.Input, "BOTTOMLEFT", 0, -12)

     self.LootItem.ItemName:ClearAllPoints()
     self.LootItem.ItemName:SetHeight(20)
     self.LootItem.ItemName:SetPoint("LEFT", self.LootItem.Icon, "RIGHT", 6, 0)
     self.LootItem.ItemName:SetPoint("RIGHT", self.LootItem, "RIGHT", -18, 0)

    self:InitializeLootItemList()

    -- Repetitions beneath the description.
    self.TargetLabel:ClearAllPoints()
    self.TargetLabel:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -22)

    -- Reset interval beneath the repetition spinner.
    -- Offset compensates for the spinner's existing 29-pixel inset.
    self.ResetIntervalLabel:ClearAllPoints()
    self.ResetIntervalLabel:SetPoint("TOPLEFT", self.Target, "BOTTOMLEFT", -29, -22)
end

function TodolooTaskDetailsFormMixin:InitializeLootItemList()
    local list = self.LootItem.List
    local view = CreateScrollBoxListLinearView()

    view:SetElementExtent(30)
    view:SetPadding(5, 5, 5, 5, 2)

    view:SetElementInitializer(
        "TodolooLootItemRowTemplate",
        function(row, elementData)
            local itemID = elementData.itemID
            row.itemID = itemID

            local name, link, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)

            row.Icon:SetTexture(icon or 134400)
            row.Name:SetText(link or name or string.format(TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_UNKNOWN, itemID))

            row.Remove:SetScript("OnClick", function()
                self:RemoveDraftLootItem(row.itemID)
            end)

            if not name then
                C_Item.RequestLoadItemDataByID(itemID)
            end
        end
    )

    ScrollUtil.InitScrollBoxListWithScrollBar(list.ScrollBox, list.ScrollBar, view)

    list.ScrollBox:SetDataProvider(CreateDataProvider())
end

function TodolooTaskDetailsFormMixin:OnShow()
    local taskInfo = self:GetTaskInfo()
    if taskInfo then
        self:Init(taskInfo)
    end
end

function TodolooTaskDetailsFormMixin:Init(taskInfo)
    local previousTask = self.currentTaskInfo and self.currentTaskInfo.taskRef
    self.currentTaskInfo = taskInfo

    self.Header:Hide()
    self.Summary:Hide()
    
    self.NameLabel:Hide()
    self.DescriptionLabel:Hide()
    self.ResetIntervalLabel:Hide()
    self.TargetLabel:Hide()

    self.Name:Hide()
    self.Description:Hide()
    self.Manual:Hide()
    self.Daily:Hide()
    self.Weekly:Hide()
    self.Target:Hide()
    self.LootItem:Hide()
    self.previewLootItemID = nil
    
    local task = taskInfo and taskInfo.taskRef
    local hasTask = task ~= nil

    if not hasTask then
        self.Header:SetText(TODOLOO_L_TASK_DETAILS_FORM_EMPTY_STATE)
        self.Header:Show()

        self.draft = nil
        self.originalDraft = nil
        self.groupReset = nil

        self.Name:ClearFocus()
        self.Description.EditBox:ClearFocus()
        self.Target:ClearFocus()

        self:NotifyDraftChanged()
        return
    end

    local _, _, group = self:GetTaskLocation()
    if not group then
        self:Init(nil)
        return
    end

    local loadFields = previousTask ~= task or self.draft == nil

    if loadFields then
        self.draft = CreateDraft(task)
        self.originalDraft = CreateDraft(task)
    end

    self.groupReset = group.reset

    self:RefreshSummary()
    self.Header:Show()
    self.Summary:Show()

    self.NameLabel:Show()
    self.DescriptionLabel:Show()
    self.ResetIntervalLabel:Show()
    self.TargetLabel:Show()

    self.Name:Show()
    self.Description:Show()
    self.Target:Show()
    self.LootItem:Show()

    if loadFields then
        self.Name:SetText(self.draft.name)

        self.Description.EditBox:SetText(self.draft.description)
        self.Description.EditBox:SetCursorPosition(0)
        self.Description:SetVerticalScroll(0)

        self.Target:SetText(self.draft.target)

        self.LootItem.Input:SetText("")
        self.LootItem.List.ScrollBox:ScrollToBegin()
    end

    self:RefreshLootItemPreview()
    self:RefreshLootItemList()
    self:RefreshResetButtons()
    self:NotifyDraftChanged()
end

function TodolooTaskDetailsFormMixin:RefreshSummary()
    local info = self:GetTaskInfo()
    if not info or not info.taskRef then
        return
    end

    local task = info.taskRef

    self.Header:SetText(task.name)
    self.Summary:SetText(string.format(
        TODOLOO_L_TASK_DETAILS_FORM_SUMMARY,
        info.character,
        task.progress,
        task.target
    ))
end

function TodolooTaskDetailsFormMixin:RefreshResetButtons()
    if not self.draft then
        self.Manual:Hide()
        self.Daily:Hide()
        self.Weekly:Hide()
        return
    end

    self.Manual:Show()
    self.Daily:Show()
    self.Weekly:Show()

    local inherited = self.groupReset ~= nil
    local selectedInterval = self.groupReset or self.draft.reset

    for _, button in ipairs(self.resetButtons) do
        button:SetChecked(button.resetInterval == selectedInterval)
        button:SetEnabled(not inherited)

        button.Text:SetFontObject(inherited and "GameFontDisableSmall" or "GameFontNormalSmall")
    end
end

function TodolooTaskDetailsFormMixin:GetLootItemInput()
    local text = self.LootItem.Input:GetText()
    text = text:match("^%s*(.-)%s*$")

    if text == "" then
        return true, nil
    end

    -- Reject decimals, scientific notation, signs, and pasted links.
    if not text:match("^%d+$") then
        return false, nil, TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_INVALID
    end

    local itemID = tonumber(text)

    -- WoW item IDs use an integer ID type. Bound the value before passing user input to the game's API.
    if not itemID
        or itemID < 1
        or itemID > 2147483647
        or not C_Item.DoesItemExistByID(itemID)
    then
        return false, nil, TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_INVALID
    end

    return true, itemID
end

function TodolooTaskDetailsFormMixin:SetLootItemPreviewMessage(message)
    self.LootItem.Icon:Hide()
    self.LootItem.ItemName:SetText(message)
end

function TodolooTaskDetailsFormMixin:ShowLootItemPreview(itemID)
    local name, link, _, _, _, _, _, _, _, icon =
        C_Item.GetItemInfo(itemID)

    if not name then
        self:SetLootItemPreviewMessage(TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_UNAVAILABLE)
        return
    end

    self.LootItem.Icon:SetTexture(icon)
    self.LootItem.Icon:Show()
    self.LootItem.ItemName:SetText(link or name)
end

function TodolooTaskDetailsFormMixin:RefreshLootItemPreview()
    self.previewLootItemID = nil

    local valid, itemID, errorMessage = self:GetLootItemInput()

    if not valid then
        self:SetLootItemPreviewMessage(errorMessage)
        return
    end

    if not itemID then
        self:SetLootItemPreviewMessage(TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_NONE)
        return
    end

    self.previewLootItemID = itemID

    if C_Item.IsItemDataCachedByID(itemID) then
        self:ShowLootItemPreview(itemID)
        return
    end

    self:SetLootItemPreviewMessage(TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_LOADING)

    C_Item.RequestLoadItemDataByID(itemID)
end

function TodolooTaskDetailsFormMixin:AddDraftLootItem()
    if not self.draft then
        return
    end

    local valid, itemID, errorMessage = self:GetLootItemInput()

    if not valid then
        UIErrorsFrame:AddMessage(errorMessage, 1, 0.2, 0.2)
        return
    end

    if not itemID then
        self.LootItem.Input:SetFocus()
        return
    end

    for _, attachedItemID in ipairs(self.draft.lootItemIDs) do
        if attachedItemID == itemID then
            UIErrorsFrame:AddMessage(
                TODOLOO_L_TASK_DETAILS_FORM_LOOT_ITEM_DUPLICATE,
                1, 0.2, 0.2
            )
            return
        end
    end

    table.insert(self.draft.lootItemIDs, itemID)

    self.LootItem.Input:SetText("")
    self:RefreshLootItemList()
    self:NotifyDraftChanged()
end

function TodolooTaskDetailsFormMixin:RemoveDraftLootItem(itemID)
    if not self.draft then
        return
    end

    for index, attachedItemID in ipairs(self.draft.lootItemIDs) do
        if attachedItemID == itemID then
            table.remove(self.draft.lootItemIDs, index)
            break
        end
    end

    self:RefreshLootItemList()
    self:NotifyDraftChanged()
end

function TodolooTaskDetailsFormMixin:RefreshLootItemList()
    local dataProvider = CreateDataProvider()

    if self.draft then
        for _, itemID in ipairs(self.draft.lootItemIDs) do
            dataProvider:Insert({
                itemID = itemID
            })
        end
    end

    self.LootItem.List.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

function TodolooTaskDetailsFormMixin:GetTaskInfo()
    return self.currentTaskInfo
end

function TodolooTaskDetailsFormMixin:GetDraft()
    if not self.draft then
        return nil
    end

    return self.draft
end

function TodolooTaskDetailsFormMixin:SetDraftChangedCallback(callback)
    self.draftChangedCallback = callback
end

function TodolooTaskDetailsFormMixin:NotifyDraftChanged()
    if self.draftChangedCallback then
        self.draftChangedCallback()
    end
end

function TodolooTaskDetailsFormMixin:HasUnsavedChanges()
    if not self.draft or not self.originalDraft then
        return false
    end

    return self.draft.name ~= self.originalDraft.name
        or self.draft.description ~= self.originalDraft.description
        or tonumber(self.draft.target) ~= tonumber(self.originalDraft.target)
        or not ItemListsEqual(self.draft.lootItemIDs, self.originalDraft.lootItemIDs)
        or (self.groupReset == nil and self.draft.reset ~= self.originalDraft.reset)
end

function TodolooTaskDetailsFormMixin:ResetDraft()
    local taskInfo = self:GetTaskInfo()
    if not taskInfo then
        return
    end

    self.draft = nil
    self:Init(taskInfo)
end

function TodolooTaskDetailsFormMixin:GetTaskLocation()
    local taskInfo = self:GetTaskInfo()
    if not taskInfo then
        return
    end

    local character = Todoloo.TaskManager:GetCharacter(taskInfo.character)
    if not character then
        return
    end

    for groupId, group in ipairs(character.groups) do
        for taskId, task in ipairs(group.tasks) do
            if  task == taskInfo.taskRef then
                return groupId, taskId, group
            end
        end
    end
end