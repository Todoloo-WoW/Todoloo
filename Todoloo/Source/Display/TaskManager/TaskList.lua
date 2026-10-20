-- *****************************************************************************************************
-- ***** GROUP LIST
-- *****************************************************************************************************

TodolooTaskListMixin = {}

function TodolooTaskListMixin:SetupScrollBox(self)
    local indent = 5;
	local padLeft = 0;
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing);

    view:SetElementFactory(function(factory, node)
        local elementData = node:GetData()
        if elementData.characterInfo then
            -- if the element is a character
            local function Initializer(characterButton, node)
                characterButton:Initialize(node)

                characterButton:SetScript("OnClick", function(button, buttonName)
                    if buttonName == "LeftButton" then
                        self:SetNodeCollapsed(node, not node:IsCollapsed())
                        button:SetCollapseState(node:IsCollapsed())
                        PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK);
                    elseif buttonName == "RightButton" then
                        ToggleDropDownMenu(1, elementData.characterInfo, self.CharacterContextMenu, "cursor")
                    end
                end)
            end
            factory("TodolooTaskListCharacterTemplate", Initializer)
        elseif elementData.groupInfo then
            -- if the element is a group
            local function Initializer(groupButton, node)
                groupButton:Initialize(node)

                groupButton:SetScript("OnClick", function(button, buttonName)
                    if buttonName == "LeftButton" and IsShiftKeyDown() then
                        self:SetNodeCollapsed(node, not node:IsCollapsed())
                        button:SetCollapseState(node:IsCollapsed())
                        PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK);
                    elseif buttonName == "RightButton" then
                        ToggleDropDownMenu(1, elementData.groupInfo, self.GroupContextMenu, "cursor")
                    end
                end)

                groupButton:SetScript("OnDoubleClick", function(button, buttonName)
                    if buttonName == "LeftButton" then
                        --enter edit mode, enabling the player to edit the group name
                        PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                        button:SetEditMode(true)
                    end
                end)
            end
            factory("TodolooTaskListGroupTemplate", Initializer);
        elseif elementData.taskInfo then
            -- if the element is a task
            local function Initializer(taskButton, node)
                taskButton.taskList = self
                taskButton:Initialize(node)

                taskButton:SetSelected(
                    self.selectionBehavior
                        and self.selectionBehavior:IsElementDataSelected(node)
                        or false
                )

                taskButton:SetScript("OnClick", function(button, buttonName, down)
                    if buttonName == "RightButton" then
                        ToggleDropDownMenu(1, button.taskInfo, self.TaskContextMenu, "cursor")
                    elseif buttonName == "LeftButton" then
                        if IsControlKeyDown() then
                            button:AdjustProgress(-1)
                        elseif IsShiftKeyDown() then
                            button:AdjustProgress(1)
                        else
                            self:GetParent():RequestTaskSelection(button.taskInfo.taskRef)
                        end
                    end
                end)
            end
            factory("TodolooTaskListTaskTemplate", Initializer);
        elseif elementData.isDivider then
			factory("TodolooTaskListDividerTemplate");
        else
			factory("Frame");
        end
    end)

    view:SetElementExtentCalculator(function(dataIndex, node)
        local elementData = node:GetData()
        local baseElementHeight = 20
        local characterPadding = 10
        local groupPadding = 5

        if elementData.characterInfo then
            return baseElementHeight + characterPadding
        end

        if elementData.taskInfo then
            return baseElementHeight
        end

        if elementData.groupInfo then
            return baseElementHeight + groupPadding
        end

        if elementData.topPadding  then
            return 1
        end

        if elementData.bottomPadding then
            return 10
        end
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    local function OnSelectionChanged(o, node, selected)
        local taskInfo = node:GetData().taskInfo
        if not taskInfo then
            return
        end

        local button = self.ScrollBox:FindFrame(node)
        if button then
            button:SetSelected(selected)
        end

        if selected then
            self:GetParent():SelectTask(taskInfo)
        end
    end

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox)
    self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self)
end

function TodolooTaskListMixin:RestoreTaskSelection(task)
    if not task then
        self:GetParent():SelectTask(nil)
        return
    end

    local dataProvider = self.ScrollBox:GetDataProvider()

    local node = dataProvider:FindElementDataByPredicate(
        function(candidate)
            local info = candidate:GetData().taskInfo
            return info and info.taskRef == task
        end,
        TreeDataProviderConstants.IncludeCollapsed
    )

    if node then
        self.selectionBehavior:SelectElementData(node)
    else
        self.selectionBehavior:ClearSelections()

        local page = self:GetParent()
        if not page.Details:HasUnsavedChanges() then
            page:SelectTask(nil)
        end
    end
end

function TodolooTaskListMixin:SetupDragBehavior()
    local dragBehavior = Todoloo.ScrollUtil.AddTaskListDragBehavior(self.ScrollBox)

    dragBehavior:SetReorderable(true)
    dragBehavior:SetDragRelativeToCursor(true)
    dragBehavior:SetAreaIntersectMargin(function(destinationElementData, sourceElementData, contextData)
        if contextData.destinationData.parentElementData == nil and not destinationElementData.isGroup and not destinationElementData.isDivider then
            return 20 * 0.5
        end

        return 20
    end)

    dragBehavior:SetDropEnter(function(factory, candidate)
        local area = candidate.area
        local candidateFrame = candidate.frame
        local data = candidate.elementData:GetData()

        if area == DragIntersectionArea.Above
            or area == DragIntersectionArea.Below then

            if not data.taskInfo and not data.groupInfo then
                return
            end

            local marker = factory("TodolooScrollBoxDragLineTemplate")
            local inset = data.groupInfo and 10 or 40

            if area == DragIntersectionArea.Above then
                marker:SetPoint("BOTTOMLEFT", candidateFrame, "TOPLEFT", inset, 0)
                marker:SetPoint("BOTTOMRIGHT", candidateFrame, "TOPRIGHT", -inset, 0)
            else
                marker:SetPoint("TOPLEFT", candidateFrame, "BOTTOMLEFT", inset, 0)
                marker:SetPoint("TOPRIGHT", candidateFrame, "BOTTOMRIGHT", -inset, 0)
            end
        elseif area == DragIntersectionArea.Inside and data.groupInfo then
            local marker = factory("TodolooScrollBoxDragGroupTemplate")

            marker:SetPoint("TOPLEFT", candidateFrame, "TOPLEFT", 0, 5)
            marker:SetPoint("BOTTOMRIGHT", candidateFrame, "BOTTOMRIGHT", 0, 1)
        end
    end)


    dragBehavior:SetNotifyDragStart(function(sourceFrame, dragging)
        sourceFrame:SetAlpha(dragging and .5 or 1)
        sourceFrame:SetMouseMotionEnabled(not dragging)
        
        if sourceFrame.GetElementData == nil then
            -- If the source frame is no longer visible in the scrollbox.
            -- This can happen if we're is scrolling whilst dragging.
            return
        end

        local node = sourceFrame:GetElementData()
        local sourceData = sourceFrame:GetData()

        if sourceData.groupInfo then
            local collapsed = dragging or self:GetSavedCollapsedState(node)

            node:SetCollapsed(collapsed)
            sourceFrame:SetCollapseState(collapsed)
        end
    end)


    dragBehavior:SetNotifyDropCandidates(function(candidateFrame, dragging, sourceElementData)
        candidateFrame:SetMouseMotionEnabled(not dragging)
        local node = candidateFrame:GetElementData()
        local candidateData = candidateFrame:GetData()
        local sourceData = sourceElementData:GetData()

        if dragging and sourceData then
            if sourceData.groupInfo and candidateData.groupInfo then
                node:SetCollapsed(true)
                candidateFrame:SetCollapseState(true)
            end

            if sourceData.character ~= candidateData.character then
                -- If the candidate frame's registered character is not the same as the source frame beign dragged,
                -- make sure to visualize that it's not possible to drag between characters
                candidateFrame:SetAlpha(.5)
            else
                -- This only exists to handle the scenario where tasks and groups on the same character
                -- disappears from the scroll box because of scrolling whilst dragging, and getting
                -- added again when being rendered back into the scroll box
                candidateFrame:SetAlpha(1)
            end
        else
            if candidateData.groupInfo then
                local collapsed = self:GetSavedCollapsedState(node)

                node:SetCollapsed(collapsed)
                candidateFrame:SetCollapseState(collapsed)
            end

            candidateFrame:SetAlpha(1)
        end
    end)


    -- Determines if the current drop case is valid.
    dragBehavior:SetDropPredicate(function(sourceElementData, contextData)
        local destinationNode = contextData.elementData
        if not destinationNode or sourceElementData == destinationNode then
            return false
        end

        local source = sourceElementData:GetData()
        local destination = destinationNode:GetData()
        local area = contextData.area

        if source.character ~= destination.character then
            return false
        end

        local betweenRows = area == DragIntersectionArea.Above
            or area == DragIntersectionArea.Below

        if source.groupInfo then
            return destination.groupInfo ~= nil and betweenRows
        end

        if source.taskInfo then
            if destination.taskInfo then
                return betweenRows
            end

            if destination.groupInfo then
                return area == DragIntersectionArea.Inside
                    and source.taskInfo.groupId ~= destination.groupInfo.id
            end
        end

        return false
    end)

    dragBehavior:SetDragPredicate(function(frame, elementData)
        local data = elementData:GetData()
        return data.taskInfo ~= nil or data.groupInfo ~= nil
    end)


    dragBehavior:SetPostDrop(function(contextData)
        local sourceData = contextData.sourceData
        local sourceElementData = sourceData.elementData:GetData()

        local destinationData = contextData.destinationData
        local destinationElementData = destinationData.elementData:GetData()

        local area = contextData.area

        if sourceElementData.groupInfo and destinationElementData.groupInfo then
            local sourceId = sourceElementData.groupInfo.id
            local newGroupId = destinationElementData.groupInfo.id
            if area == DragIntersectionArea.Below then
                newGroupId = newGroupId + 1
            end

            PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
            Todoloo.TaskManager:MoveGroup(sourceId, newGroupId, destinationElementData.character)

        elseif sourceElementData.taskInfo then
            local sourceId = sourceElementData.taskInfo.id
            local sourceGroupId = sourceElementData.taskInfo.groupId
            if area == DragIntersectionArea.Inside and destinationElementData.groupInfo and destinationElementData.groupInfo.id ~= sourceElementData.taskInfo.groupId then
                if destinationElementData.groupInfo.id == sourceElementData.taskInfo.groupId then
                    return
                end

                PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, destinationElementData.groupInfo.id, nil, destinationElementData.character)

            elseif destinationElementData.taskInfo and destinationElementData.taskInfo.groupId ~= sourceGroupId then
                local offset = 0
                if area == DragIntersectionArea.Below then
                    offset = 1
                end

                PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                local newTaskId = destinationElementData.taskInfo.id + offset
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, destinationElementData.taskInfo.groupId, newTaskId, destinationElementData.character)

            elseif destinationElementData.taskInfo then
                local offset = 0
                if area == DragIntersectionArea.Below then
                    offset = 1
                end

                PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                local newTaskId = destinationElementData.taskInfo.id + offset
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, sourceGroupId, newTaskId, destinationElementData.character)
            end
        end
    end)
end

function TodolooTaskListMixin:OnLoad()
    Todoloo.EventBus:RegisterSource(self, "task_list")

    self.collapsedCharacters = {}
    self.collapsedGroups = setmetatable({}, { __mode = "k" })

    self:SetupScrollBox(self)
    self:SetupDragBehavior()

    UIDropDownMenu_SetInitializeFunction(self.CharacterContextMenu, GenerateClosure(self.InitializeCharacterContextMenu, self))
    UIDropDownMenu_SetDisplayMode(self.CharacterContextMenu, "MENU")

    UIDropDownMenu_SetInitializeFunction(self.GroupContextMenu, GenerateClosure(self.InitializeGroupContextMenu, self))
    UIDropDownMenu_SetDisplayMode(self.GroupContextMenu, "MENU")

    UIDropDownMenu_SetInitializeFunction(self.TaskContextMenu, GenerateClosure(self.InitializeTaskContextMenu, self))
    UIDropDownMenu_SetDisplayMode(self.TaskContextMenu, "MENU")
end

function TodolooTaskListMixin:OnShow()
    Todoloo.Tasks.InitFilterMenu(self.FilterButton)
end

function TodolooTaskListMixin:UpdateFilterResetVisibility()
    self.FilterButton.ResetButton:SetShown(not Todoloo.Tasks.IsUsingDefaultFilters())
end

function TodolooTaskListMixin:InitializeCharacterContextMenu(dropDown, level)
    local characterInfo = UIDROPDOWNMENU_MENU_VALUE

    Todoloo.Sharing.AddMenu(characterInfo.name, nil, nil, level)

    local info = UIDropDownMenu_CreateInfo()

    info.notCheckable = true
    info.text = TODOLOO_L_TASK_MANAGER_CHARACTER_ADD_NEW_GROUP
    info.func = function() self:AddNewGroup(characterInfo) end
    UIDropDownMenu_AddButton(info, level)
end

function TodolooTaskListMixin:InitializeGroupContextMenu(dropDown, level)
    level = level or 1

    if level ~= 1 then
        local menuValue = UIDROPDOWNMENU_MENU_VALUE

        if level == 2
            and type(menuValue) == "table"
            and menuValue.todolooCopyGroup
        then
            self:InitializeGroupCopySubmenu(menuValue, level)
        end

        return
    end

    local groupInfo = UIDROPDOWNMENU_MENU_VALUE

    Todoloo.Sharing.AddMenu(groupInfo.character, groupInfo.id, nil, level)

    local info = UIDropDownMenu_CreateInfo()

    info.isTitle = true
    info.notCheckable = true
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_RESET_INTERVAL_LABEL
    UIDropDownMenu_AddButton(info, level)

    info.isTitle = false
    info.disabled = false

    info.notCheckable = false
    info.checked = groupInfo.reset == nil
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_RESET_INTERVAL_NONE
    info.func = function() self:SetGroupInterval(groupInfo, nil) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = false
    info.checked = groupInfo.reset == TODOLOO_RESET_INTERVALS.Manually
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_RESET_INTERVAL_MANUALLY
    info.func = function() self:SetGroupInterval(groupInfo, TODOLOO_RESET_INTERVALS.Manually) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = false
    info.checked = groupInfo.reset == TODOLOO_RESET_INTERVALS.Daily
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_RESET_INTERVAL_DAILY
    info.func = function() self:SetGroupInterval(groupInfo, TODOLOO_RESET_INTERVALS.Daily) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = false
    info.checked = groupInfo.reset == TODOLOO_RESET_INTERVALS.Weekly
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_RESET_INTERVAL_WEEKLY
    info.func = function() self:SetGroupInterval(groupInfo, TODOLOO_RESET_INTERVALS.Weekly) end
    UIDropDownMenu_AddButton(info, level)

    UIDropDownMenu_AddSpace(level)

    info.isTitle = true
    info.notCheckable = true
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_ACTIONS_LABEL
    UIDropDownMenu_AddButton(info, level)

    local copyInfo = UIDropDownMenu_CreateInfo()
    copyInfo.text = TODOLOO_L_TASK_MANAGER_GROUP_COPY_MENU
    copyInfo.notCheckable = true
    copyInfo.hasArrow = true
    copyInfo.value = {
        todolooCopyGroup = true,
        sourceCharacter = groupInfo.character,
        sourceGroup = Todoloo.TaskManager:GetGroup(
            groupInfo.id,
            groupInfo.character
        ),
    }

    UIDropDownMenu_AddButton(copyInfo, level)
    
    info.isTitle = false
    info.disabled = false
    
    info.notCheckable = true
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_ACTIONS_ADD_NEW_TASK
    info.func = function() self:AddNewTask(groupInfo) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = true
    info.text = TODOLOO_L_TASK_MANAGER_GROUP_ACTIONS_DELETE
    info.func = function() 
        local numTasks = Todoloo.TaskManager:GetNumTasks(groupInfo.id, groupInfo.character)
        if numTasks > 0 then
            -- if the group has nested tasks, we should ask the player for confirmation
            StaticPopup_Show("TODLOO_DELETE_GROUP", groupInfo.name, nil, { groupInfo = groupInfo })
        else
            Todoloo.TaskManager:RemoveGroup(groupInfo.id, groupInfo.character)
        end
    end

    UIDropDownMenu_AddButton(info, level)
end

function TodolooTaskListMixin:InitializeGroupCopySubmenu(menuValue, level)
    local destinations = {}

    for _, character in ipairs(Todoloo.TaskManager:GetAllCharacterNames()) do
        if character ~= menuValue.sourceCharacter then
            table.insert(destinations, character)
        end
    end

    table.sort(destinations, function(first, second)
        return strcmputf8i(first, second) < 0
    end)

    if #destinations == 0 then
        local info = UIDropDownMenu_CreateInfo()
        info.text = TODOLOO_L_TASK_MANAGER_GROUP_COPY_NO_CHARACTERS
        info.notCheckable = true
        info.disabled = true
        UIDropDownMenu_AddButton(info, level)
        return
    end

    for _, character in ipairs(destinations) do
        local destinationCharacter = character
        local info = UIDropDownMenu_CreateInfo()

        info.text = destinationCharacter
        info.notCheckable = true
        info.func = function()
            CloseDropDownMenus()

            local copiedGroup = Todoloo.TaskManager:CopyGroupToCharacter(menuValue.sourceGroup, menuValue.sourceCharacter, destinationCharacter)

            if copiedGroup then
                Todoloo.Messenger.SlashMessage(string.format(TODOLOO_L_TASK_MANAGER_GROUP_COPY_SUCCESS, copiedGroup.name, destinationCharacter))
            else
                UIErrorsFrame:AddMessage(TODOLOO_L_TASK_MANAGER_GROUP_COPY_FAILED, 1, 0.2, 0.2)
            end
        end

        UIDropDownMenu_AddButton(info, level)
    end
end

function TodolooTaskListMixin:InitializeTaskContextMenu(dropDown, level)
    local taskInfo = UIDROPDOWNMENU_MENU_VALUE
    
    Todoloo.Sharing.AddMenu(taskInfo.character, taskInfo.groupId, taskInfo.id, level)

    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.text = TODOLOO_L_TASK_MANAGER_TASK_ACTION_DELETE
    info.func = function()
        self:DeleteTask(taskInfo)
    end

    UIDropDownMenu_AddButton(info, level)
end



function TodolooTaskListMixin:IsTaskProgressUpdate(groupId, taskId, character)
    local dataProvider = self.ScrollBox:GetDataProvider()
    if not dataProvider then
        return false
    end

    character = character or Todoloo.Utils.GetCharacterFullName()

    local node = dataProvider:FindElementDataByPredicate(
        function(candidate)
            local info = candidate:GetData().taskInfo

            return info
                and info.groupId == groupId
                and info.id == taskId
                and info.character == character
        end,
        TreeDataProviderConstants.IncludeCollapsed
    )

    if not node then
        return false
    end

    local info = node:GetData().taskInfo
    local task = info.taskRef

    return info.name == task.name
        and info.description == task.description
        and info.reset == task.reset
        and info.target == task.target
end

function TodolooTaskListMixin:RefreshProgress()
    local dataProvider = self.ScrollBox:GetDataProvider()
    if not dataProvider then
        return
    end

    for _, node in dataProvider:EnumerateEntireRange() do
        local data = node:GetData()
        local button = self.ScrollBox:FindFrame(node)

        if data.taskInfo then
            local info = data.taskInfo
            local task = info.taskRef

            info.progress = task.progress
            info.completed = task.completed

            if button then
                button:Initialize(node)
            end
        elseif data.groupInfo and button then
            button:RefreshLabel()
        end
    end
end

function TodolooTaskListMixin:SetGroupInterval(groupInfo, resetInterval)
    if groupInfo.reset == resetInterval then
        -- reset interval already set to the given value
        return
    end

    groupInfo.reset = resetInterval
    self:UpdateGroup(groupInfo)
end

function TodolooTaskListMixin:AddNewGroup(characterInfo)
    Todoloo.TaskManager:AddGroup(TODOLOO_L_TASK_MANAGER_DEFAULT_GROUP_NAME, characterInfo.name)
end

function TodolooTaskListMixin:AddNewTask(groupInfo)
    local page = self:GetParent()
    page:ConfirmDiscardChanges(function()
        Todoloo.TaskManager:AddTask(groupInfo.id, TODOLOO_L_TASK_MANAGER_DEFAULT_TASK_NAME, nil, 1, 0, nil, groupInfo.character)
    end)
end

function TodolooTaskListMixin:DeleteTask(taskInfo)
    Todoloo.TaskManager:RemoveTask(taskInfo.groupId, taskInfo.id, taskInfo.character)
end

function TodolooTaskListMixin:RevealGroup(groupInfo, scrollToTask)
    if not groupInfo then
        return
    end

    local dataProvider = self.ScrollBox:GetDataProvider()

    local node = dataProvider:FindElementDataByPredicate(
        function(candidate)
            local info = candidate:GetData().groupInfo
            return info and info.id == groupInfo.id and info.character == groupInfo.character
        end,
        TreeDataProviderConstants.IncludeCollapsed
    )

    if not node then
        return
    end

    local parent = node:GetParent()
    while parent do
        if parent:IsCollapsed() then
            self:SetNodeCollapsed(parent, false)
        end

        parent = parent:GetParent()
    end

    if scrollToTask then
        self.ScrollBox:ScrollToElementData(node)
    end

    return node
end

function TodolooTaskListMixin:UpdateGroup(groupInfo)
    Todoloo.TaskManager:UpdateGroup(
        groupInfo.id,
        groupInfo.name,
        groupInfo.reset,
        groupInfo.character
    )
end

function TodolooTaskListMixin:GetSavedCollapsedState(node)
    if self.searching then
        return false
    end

    local data = node:GetData()

    if data.characterInfo then
        return self.collapsedCharacters[data.character] == true
    elseif data.groupInfo and data.groupInfo.groupRef then
        return self.collapsedGroups[data.groupInfo.groupRef] == true
    end

    return false
end

function TodolooTaskListMixin:SetNodeCollapsed(node, collapsed)
    node:SetCollapsed(collapsed)

    -- Search expansion is temporary
    if self.searching then
        return
    end

    local data = node:GetData()

    if data.characterInfo then
        self.collapsedCharacters[data.character] = collapsed
    elseif data.groupInfo and data.groupInfo.groupRef then
        self.collapsedGroups[data.groupInfo.groupRef] = collapsed
    end
end

function TodolooTaskListMixin:ApplyCollapsedState(dataProvider, searching)
    self.searching = searching

    for _, node in dataProvider:EnumerateEntireRange() do
        local data = node:GetData()

        if data.characterInfo or data.groupInfo then
            node:SetCollapsed(
                self:GetSavedCollapsedState(node),
                TreeDataProviderConstants.RetainChildCollapse,
                TreeDataProviderConstants.SkipInvalidation
            )
        end
    end

    dataProvider:Invalidate()
end

-- *****************************************************************************************************
-- ***** CHARACTER
-- *****************************************************************************************************
TodolooTaskListCharacterMixin = {}

function TodolooTaskListCharacterMixin:Initialize(node)
    local elementData = node:GetData()
    local characterInfo = elementData.characterInfo

    self.Label:SetText(characterInfo.name)
    self.Label:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

    self:SetCollapseState(node:IsCollapsed());
end

function TodolooTaskListCharacterMixin:SetCollapseState(collapsed)
    local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse";
	self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

-- *****************************************************************************************************
-- ***** GROUP
-- *****************************************************************************************************
TodolooTaskListGroupMixin = {}

function TodolooTaskListGroupMixin:Initialize(node)
    self.groupInfo = node:GetData().groupInfo

    self.Name:SetText(self.groupInfo.name)
    self:RefreshLabel()
    self:SetCollapseState(node:IsCollapsed())
    self:SetResetInterval()
end

function TodolooTaskListGroupMixin:RefreshLabel()
    local labelText = self.groupInfo.name

    if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_GROUP_PROGRESS_TEXT) then
        local completed = Todoloo.TaskManager:GetNumCompletedTasks(self.groupInfo.id, self.groupInfo.character)
        local total = Todoloo.TaskManager:GetNumTasks(self.groupInfo.id, self.groupInfo.character)

        labelText = labelText .. " (" .. completed .. "/" .. total .. ")"
    end

    self.Label:SetText(labelText)
end

function TodolooTaskListGroupMixin:SetResetInterval()
    self.ResetIcon:SetWidth(1)
    self.ResetIcon:Hide()

    if self.groupInfo.reset ~= nil then
        if self.groupInfo.reset == TODOLOO_RESET_INTERVALS.Manually then
            self.ResetIcon:SetTexture("Interface/GossipFrame/AvailableQuestIcon")
        elseif self.groupInfo.reset == TODOLOO_RESET_INTERVALS.Daily then
            self.ResetIcon:SetAtlas("questlog-questtypeicon-daily", false)
        elseif self.groupInfo.reset == TODOLOO_RESET_INTERVALS.Weekly then
            self.ResetIcon:SetAtlas("questlog-questtypeicon-weekly", false)
        end

        self.ResetIcon:SetSize(14, 14)
        self.ResetIcon:Show()
    end
end

function TodolooTaskListGroupMixin:SetCollapseState(collapsed)
    local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse"
    self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
    self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
end

function TodolooTaskListGroupMixin:SetEditMode(enable)
    if enable then
        self.Label:Hide()
        self.Name:Show()
        self.Name:SetFocus()
    else
        self.Label:Show()
        self.Name:Hide()
    end
end

function TodolooTaskListGroupMixin:OnEditFocusLost()
    self:Save()
end

function TodolooTaskListGroupMixin:Save()
    local isDirty = false

    local newName = self.Name:GetText()
    if self.groupInfo.name ~= newName then
        self.groupInfo.name = newName
        isDirty = true
    end

    if isDirty then
        Todoloo.TaskManager:UpdateGroup(self.groupInfo.id, newName, self.groupInfo.reset, self.groupInfo.character)
    end

    self:SetEditMode(false)
end

-- *****************************************************************************************************
-- ***** TASK
-- *****************************************************************************************************
TodolooTaskListTaskMixin = {}

function TodolooTaskListTaskMixin:Initialize(node)
    local elementData = node:GetData()
    self.taskInfo = elementData.taskInfo

    self.Label:SetText(Todoloo.Utils.GetTaskDisplayText(self.taskInfo))

    if self.taskInfo.completed then
        self.Label:SetVertexColor(DISABLED_FONT_COLOR:GetRGB())
        self.Check:Show()
    else
        self.Label:SetVertexColor(PROFESSION_RECIPE_COLOR:GetRGB())
        self.Check:Hide()
    end

    self.ResetIcon:Hide()

    if self.taskInfo.reset ~= nil then
        if self.taskInfo.reset == TODOLOO_RESET_INTERVALS.Manually then
            self.ResetIcon:SetTexture("Interface/GossipFrame/AvailableQuestIcon")
        elseif self.taskInfo.reset == TODOLOO_RESET_INTERVALS.Daily then
            self.ResetIcon:SetAtlas("questlog-questtypeicon-daily", false)
        elseif self.taskInfo.reset == TODOLOO_RESET_INTERVALS.Weekly then
            self.ResetIcon:SetAtlas("questlog-questtypeicon-weekly", false)
        end

        self.ResetIcon:SetSize(14, 14)

        self.ResetIcon:Show()
    end
end

function TodolooTaskListTaskMixin:SetSelected(selected)
    self.SelectedOverlay:SetShown(selected)
end

function TodolooTaskListTaskMixin:AdjustProgress(amount)
    local info = self.taskInfo

    Todoloo.TaskManager:AdjustTaskProgress(info.groupId, info.id, amount, info.character)
end

-- *****************************************************************************************************
-- ***** POPUPS
-- *****************************************************************************************************

StaticPopupDialogs["TODLOO_DELETE_GROUP"] = {
    text = TODOLOO_L_TASK_MANAGER_GROUP_DELETE_CONFIRMATION,
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        Todoloo.TaskManager:RemoveGroup(data.groupInfo.id, data.groupInfo.character)
    end,
    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    hideOnEscape = 1
}
